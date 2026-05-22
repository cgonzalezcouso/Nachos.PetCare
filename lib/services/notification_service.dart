import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:nachos_pet_care_flutter/config/app_logger.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String _currentTimeZone = 'UTC';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      
      try {
        final dynamic tzResult = await FlutterTimezone.getLocalTimezone();
        _currentTimeZone = tzResult.toString();
        AppLogger.info('Zona horaria detectada: $_currentTimeZone');
        try {
          tz.setLocalLocation(tz.getLocation(_currentTimeZone));
          AppLogger.info('Ubicación local establecida: $_currentTimeZone');
        } catch (e) {
          AppLogger.warn('No se pudo encontrar la ubicación para $_currentTimeZone, usando UTC');
          tz.setLocalLocation(tz.getLocation('UTC'));
        }
      } catch (e) {
        _currentTimeZone = 'error';
        AppLogger.error('No se pudo obtener la zona horaria local', error: e);
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
          const InitializationSettings(
        android: initializationSettingsAndroid,
      );

      AppLogger.info('Llamando a _flutterLocalNotificationsPlugin.initialize...');
      await _flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );
      AppLogger.info('Plugin de notificaciones inicializado');

      _isInitialized = true;
      AppLogger.info('NotificationService inicializado correctamente');
    } catch (e, stackTrace) {
      AppLogger.error('Error al inicializar NotificationService', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  String getCurrentTimeZone() => _currentTimeZone;

  Future<void> showImmediateNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'immediate_channel',
      'Notificaciones Inmediatas',
      channelDescription: 'Canal para notificaciones de prueba e inmediatas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_isInitialized) await initialize();

    final int notificationId = id.hashCode.abs();
    
    // Convertir DateTime a TZDateTime
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // Si la fecha es en el pasado, no programar
    if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      AppLogger.warn('Intentando programar notificación en el pasado ($tzScheduledDate). Omitiendo.');
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reminders_channel',
      'Recordatorios de Mascotas',
      channelDescription: 'Canal para recordatorios de vacunas, citas y medicinas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: tzScheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // En v21, uiLocalNotificationDateInterpretation se ha vuelto implícito o ha cambiado
      // por defecto se comporta como Absolute Time si no se especifica matchComponents
    );
    
    AppLogger.info('Notificación programada: $id para $tzScheduledDate');
  }

  Future<void> cancelReminder(String id) async {
    final int notificationId = id.hashCode.abs();
    await _flutterLocalNotificationsPlugin.cancel(id: notificationId);
    AppLogger.info('Notificación cancelada: $id');
  }
}
