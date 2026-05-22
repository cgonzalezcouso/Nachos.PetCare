import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nachos_pet_care_flutter/models/user.dart' as app_user;
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/config/supabase_config.dart';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';

enum AuthProvider { email, google, microsoft, facebook }

class AuthService {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }
  
  final DatabaseService _dbService = getIt<DatabaseService>();
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: SupabaseConfig.googleWebClientId,
    scopes: ['email', 'profile'],
  );

  // Stream del estado de autenticación
  Stream<AuthState> get authStateChanges {
    if (_supabase == null) return const Stream.empty();
    return _supabase!.auth.onAuthStateChange;
  }

  // Usuario actual de Supabase
  User? get currentSupabaseUser => _supabase?.auth.currentUser;

  // Verificar si está logueado
  bool get isLoggedIn => _supabase?.auth.currentUser != null;

  // ID del usuario actual
  String? get currentUserId => _supabase?.auth.currentUser?.id;

  // Registro con email y contraseña
  Future<app_user.User> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String surname,
    String? address,
    String? postalCode,
    String? city,
    String? phone,
  }) async {
    if (_supabase == null) {
      throw Exception('Supabase no está configurado');
    }
    
    try {
      final response = await _supabase!.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'surname': surname,
        },
      );

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        throw Exception('Error al crear la cuenta');
      }

      final user = app_user.User(
        id: supabaseUser.id,
        email: email,
        name: name,
        surname: surname,
        address: address,
        postalCode: postalCode,
        city: city,
        phone: phone,
        createdAt: DateTime.now(),
      );

      // Guardar en base de datos local
      await _dbService.insertUser(user);

      return user;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Login con email y contraseña
  Future<app_user.User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (_supabase == null) {
      throw Exception('Supabase no está configurado');
    }
    
    try {
      final response = await _supabase!.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        throw Exception('Error al iniciar sesión');
      }

      return await _getOrCreateUser(supabaseUser);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Login con Google - Método OAuth nativo de Supabase
  Future<app_user.User> signInWithGoogle() async {
    if (_supabase == null) {
      throw Exception('Supabase no está configurado');
    }
    
    try {
      AppLogger.auth('Iniciando Google Sign-In con OAuth nativo...');
      
      final completer = Completer<app_user.User>();
      StreamSubscription? subscription;

      subscription = _supabase!.auth.onAuthStateChange.listen((data) async {
        if (data.event == AuthChangeEvent.signedIn && data.session != null) {
          AppLogger.auth('Evento de Login recibido (Google)!');
          subscription?.cancel();
          try {
            final user = await _getOrCreateUser(data.session!.user);
            if (!completer.isCompleted) completer.complete(user);
          } catch (e) {
            if (!completer.isCompleted) completer.completeError(e);
          }
        }
      });

      // En Web especificamos la URL de origen de la aplicación web (p.ej. http://localhost:XXXX/),
      // pero en Android y Windows usamos la URL de redirección personalizada (custom scheme).
      final String redirectTo = kIsWeb ? "${Uri.base.origin}/" : SupabaseConfig.redirectUrl;

      await _supabase!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      AppLogger.auth('Esperando autenticación...');
      
      // Timeout de seguridad (60 segundos)
      Future.delayed(const Duration(seconds: 60), () {
        if (!completer.isCompleted) {
          subscription?.cancel();
          completer.completeError(Exception('Tiempo de espera agotado. Inténtalo de nuevo.'));
        }
      });

      return completer.future;
    } on AuthException catch (e) {
      AppLogger.error('AUTH ERROR (Supabase Google)', error: e.message, stackTrace: StackTrace.current);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('UNEXPECTED GOOGLE ERROR', error: e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  // Login con Microsoft
  Future<app_user.User> signInWithMicrosoft() async {
    if (_supabase == null) {
      throw Exception('Supabase no está configurado');
    }
    
    try {
      AppLogger.auth('Iniciando Microsoft Sign-In...');
      
      // En Web especificamos la URL de origen de la aplicación web (p.ej. http://localhost:XXXX/),
      // pero en Android y Windows usamos la URL de redirección personalizada (custom scheme).
      final String redirectTo = kIsWeb ? "${Uri.base.origin}/" : SupabaseConfig.redirectUrl;

      // 1. Iniciar el flujo de OAuth
      final response = await _supabase!.auth.signInWithOAuth(
        OAuthProvider.azure,
        redirectTo: redirectTo,
        authScreenLaunchMode: LaunchMode.externalApplication,
        scopes: 'openid profile email offline_access',
      );

      if (!response) {
        throw Exception('Error al iniciar sesión con Microsoft');
      }

      AppLogger.auth('Esperando autenticación de Microsoft...');
      
      final completer = Completer<app_user.User>();
      StreamSubscription? subscription;

      subscription = _supabase!.auth.onAuthStateChange.listen((data) async {
        if (data.event == AuthChangeEvent.signedIn && data.session != null) {
          AppLogger.auth('Evento de Login recibido (Microsoft)!');
          subscription?.cancel();
          try {
            final user = await _getOrCreateUser(data.session!.user);
            if (!completer.isCompleted) completer.complete(user);
          } catch (e) {
            if (!completer.isCompleted) completer.completeError(e);
          }
        }
      });

      // 3. Timeout de seguridad
      Future.delayed(const Duration(seconds: 60), () {
        if (!completer.isCompleted) {
          subscription?.cancel();
          completer.completeError(Exception('Tiempo de espera agotado. Inténtalo de nuevo.'));
        }
      });

      return completer.future;

    } on AuthException catch (e) {
      AppLogger.error('Error de autenticación Microsoft', error: e.message);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Error inesperado Microsoft', error: e);
      rethrow;
    }
  }

  // Login con Facebook
  Future<app_user.User> signInWithFacebook() async {
    if (_supabase == null) {
      throw Exception('Supabase no está configurado');
    }
    
    try {
      AppLogger.auth('Iniciando Facebook Sign-In...');
      
      // En Web especificamos la URL de origen de la aplicación web (p.ej. http://localhost:XXXX/),
      // pero en Android y Windows usamos la URL de redirección personalizada (custom scheme).
      final String redirectTo = kIsWeb ? "${Uri.base.origin}/" : SupabaseConfig.redirectUrl;

      // 1. Iniciar el flujo de OAuth
      final response = await _supabase!.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: redirectTo,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!response) {
        throw Exception('Error al iniciar sesión con Facebook');
      }

      AppLogger.auth('Esperando autenticación de Facebook...');
      
      final completer = Completer<app_user.User>();
      StreamSubscription? subscription;

      subscription = _supabase!.auth.onAuthStateChange.listen((data) async {
        if (data.event == AuthChangeEvent.signedIn && data.session != null) {
          AppLogger.auth('Evento de Login recibido (Facebook)!');
          subscription?.cancel();
          try {
            final user = await _getOrCreateUser(data.session!.user);
            if (!completer.isCompleted) completer.complete(user);
          } catch (e) {
            if (!completer.isCompleted) completer.completeError(e);
          }
        }
      });

      // 3. Timeout de seguridad
      Future.delayed(const Duration(seconds: 60), () {
        if (!completer.isCompleted) {
          subscription?.cancel();
          completer.completeError(Exception('Tiempo de espera agotado. Inténtalo de nuevo.'));
        }
      });

      return completer.future;

    } on AuthException catch (e) {
      AppLogger.error('Error de autenticación Facebook', error: e.message);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Error inesperado Facebook', error: e);
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    // Google Sign-In no está disponible en todas las plataformas (ej. Windows).
    // Capturamos cualquier error para que no bloquee el cierre de sesión de Supabase.
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    if (_supabase != null) {
      await _supabase!.auth.signOut();
    }
  }

  // Obtener o crear usuario en base de datos local
  Future<app_user.User> _getOrCreateUser(User supabaseUser) async {
    // Buscar usuario existente
    final existingUser = await _dbService.getUser(supabaseUser.id);

    // Crear/Obtener campos a partir de los metadatos de Supabase
    final metadata = supabaseUser.userMetadata ?? {};

    // Obtener campos de metadatos con fallbacks
    String name = metadata['name'] as String? ?? 
                  metadata['full_name'] as String? ?? 
                  metadata['given_name'] as String? ?? '';
    String surname = metadata['surname'] as String? ?? 
                     metadata['family_name'] as String? ?? '';

    if (name.isEmpty) {
      // Fallback OAuth: parsear full_name
      final fullName = metadata['full_name'] as String? ?? '';
      final parts = fullName.trim().split(' ');
      name = parts.isNotEmpty ? parts.first : '';
      surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    // Último fallback: usar el prefijo del email
    if (name.isEmpty) {
      name = (supabaseUser.email ?? '').split('@').first;
    }

    final avatarUrl = metadata['avatar_url'] as String? ??
                      metadata['picture'] as String?;

    if (existingUser != null) {
      // Si el nombre local está vacío, es 'Usuario', o difiere del de los metadatos de Google,
      // actualizamos los datos locales para reflejar la información más reciente de OAuth.
      if (existingUser.name.isEmpty || 
          existingUser.name == 'Usuario' || 
          (name.isNotEmpty && existingUser.name != name) ||
          (avatarUrl != null && existingUser.profilePhotoPath != avatarUrl)) {
        final updatedUser = existingUser.copyWith(
          name: name.isNotEmpty ? name : existingUser.name,
          surname: surname.isNotEmpty ? surname : existingUser.surname,
          profilePhotoPath: avatarUrl ?? existingUser.profilePhotoPath,
        );
        await _dbService.updateUser(updatedUser);
        return updatedUser;
      }
      return existingUser;
    }

    final user = app_user.User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: name,
      surname: surname,
      profilePhotoPath: avatarUrl,
      createdAt: DateTime.now(),
    );

    await _dbService.insertUser(user);
    return user;
  }

  // Obtener usuario actual. Primero busca en BD local; si no existe
  // (sesión persistida pero BD local vacía, p.ej. en Windows escritorio)
  // lo construye a partir de los metadatos de Supabase y lo persiste.
  Future<app_user.User?> getCurrentUser() async {
    final supabaseUser = currentSupabaseUser;
    if (supabaseUser == null) return null;

    // 1. Intentar desde BD local
    final localUser = await _dbService.getUser(supabaseUser.id);
    if (localUser != null) return localUser;

    // 2. No existe en BD local → construir desde metadatos de Supabase y guardar
    AppLogger.auth('Usuario no encontrado en BD local, creando desde Supabase...');
    return await _getOrCreateUser(supabaseUser);
  }

  // Actualizar perfil
  Future<void> updateProfile(app_user.User user) async {
    await _dbService.updateUser(user);
  }

  // Manejar excepciones de Supabase Auth con validación de contraseña mejorada
  Exception _handleAuthException(AuthException e) {
    final message = e.message.toLowerCase();
    
    if (message.contains('user not found') || message.contains('invalid login')) {
      return Exception('Correo o contraseña incorrectos');
    }
    if (message.contains('email already')) {
      return Exception('El correo ya está registrado');
    }
    if (message.contains('weak password') || message.contains('password')) {
      return Exception(
        'La contraseña debe tener al menos 8 caracteres, '
        'incluyendo mayúsculas, minúsculas y números',
      );
    }
    if (message.contains('invalid email')) {
      return Exception('Correo electrónico no válido');
    }
    
    return Exception('Error de autenticación. Inténtalo de nuevo.');
  }
}
