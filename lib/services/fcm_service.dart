import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';

class FCMService {
  static bool get _isSupportedPlatform => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static bool _initialized = false;
  static Future<void>? _initFuture;

  static Future<void> initialize() async {
    if (!_isSupportedPlatform) {
      AppLogger.info('FCM: Plataforma no compatible con FCM remoto. Omitiendo.');
      return;
    }
    _initFuture = _doInitialize();
    await _initFuture;
  }

  static Future<void> _doInitialize() async {
    try {
      AppLogger.info('FCM: Inicializando Firebase Core...');
      await Firebase.initializeApp();
      _initialized = true;
      AppLogger.info('FCM: Firebase Core inicializado');

      final messaging = FirebaseMessaging.instance;

      // Escuchar cambios de token FCM y sincronizarlos
      messaging.onTokenRefresh.listen((token) {
        _syncTokenToSupabase(token);
      });

      // Configurar manejador para notificaciones en segundo plano (Background/Terminated)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Escuchar notificaciones en primer plano (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        AppLogger.info('FCM: Notificación recibida en primer plano: ${message.notification?.title}');
      });

      AppLogger.info('FCM: Inicializado correctamente');
    } catch (e, stackTrace) {
      AppLogger.error('FCM: Error al inicializar FCM', error: e, stackTrace: stackTrace);
    }
  }

  static Future<void> requestPermissionsAndSync() async {
    if (!_isSupportedPlatform) return;

    try {
      // Esperar a que la inicialización asíncrona termine si está en progreso
      if (_initFuture != null) {
        await _initFuture;
      }

      if (!_initialized) {
        AppLogger.warn('FCM: Intentando solicitar permisos pero FCM no está inicializado.');
        return;
      }

      AppLogger.info('FCM: Solicitando permisos de notificación al usuario...');

      // En Android, usar permission_handler para solicitar de forma explícita el permiso del sistema (requerido para Android 13+)
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        AppLogger.info('FCM: Estado actual de permisos de notificación: $status');
        if (!status.isGranted) {
          final result = await Permission.notification.request();
          AppLogger.info('FCM: Resultado de permission_handler para notificaciones: $result');
        }
      }

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      AppLogger.info('FCM: Resultado de permisos de Firebase: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized || 
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        AppLogger.info('FCM: Permisos de notificaciones concedidos');
        final token = await messaging.getToken();
        if (token != null) {
          await _syncTokenToSupabase(token);
        }
      } else {
        AppLogger.warn('FCM: Permisos de notificaciones denegados por el usuario');
      }
    } catch (e) {
      AppLogger.error('FCM: Error al solicitar permisos FCM', error: e);
    }
  }

  static Future<void> _syncTokenToSupabase(String token) async {
    if (!_isSupportedPlatform) return;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        AppLogger.info('FCM: No hay usuario autenticado. Omite sincronización de token');
        return;
      }

      AppLogger.info('FCM: Sincronizando token FCM con Supabase...');
      await Supabase.instance.client.from('user_device_tokens').upsert({
        'user_id': user.id,
        'fcm_token': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
      }, onConflict: 'fcm_token');
      AppLogger.info('FCM: Token FCM sincronizado correctamente');
    } catch (e) {
      AppLogger.error('FCM: Error al sincronizar token FCM con Supabase', error: e);
    }
  }
}

// Manejador global para segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.info("FCM: Notificación recibida en segundo plano (Background ID: ${message.messageId})");
}
