import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nachos_pet_care_flutter/models/user.dart' as app_user;
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/config/supabase_config.dart';

enum AuthProvider { email, google, facebook, microsoft }

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
      debugPrint('🔐 Iniciando Google Sign-In con OAuth nativo...');
      
      await _supabase!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseConfig.redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      debugPrint('🔐 Esperando autenticación...');
      
      // Esperar a que se complete la autenticación
      await Future.delayed(const Duration(seconds: 2));
      
      final supabaseUser = _supabase!.auth.currentUser;
      
      if (supabaseUser == null) {
        throw Exception('Error al iniciar sesión con Google');
      }

      debugPrint('✅ Usuario autenticado con Supabase: ${supabaseUser.email}');
      
      return await _getOrCreateUser(supabaseUser);
    } on AuthException catch (e) {
      debugPrint('❌ Error de autenticación: ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en Google Sign-In: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  // Login con Facebook
  Future<app_user.User> signInWithFacebook() async {
    if (_supabase == null) {
      throw Exception('Supabase no está configurado');
    }
    
    try {
      // 1. Iniciar el flujo de OAuth
      final response = await _supabase!.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: SupabaseConfig.redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!response) {
        throw Exception('Error al iniciar sesión con Facebook');
      }

      // 2. Esperar a que el usuario complete el login y Supabase notifique el evento
      debugPrint('🔐 Esperando autenticación de Facebook...');
      
      final completer = Completer<app_user.User>();
      StreamSubscription? subscription;

      subscription = _supabase!.auth.onAuthStateChange.listen((data) async {
        debugPrint('🔔 Evento Auth Recibido: ${data.event}'); // LOG NUEVO
        if (data.session != null) {
             debugPrint('   Session User: ${data.session!.user.email}');
        } else {
             debugPrint('   Session es NULL');
        }

        if (data.event == AuthChangeEvent.signedIn && data.session != null) {
          debugPrint('✅ Evento de Login recibido!');
          subscription?.cancel();
          try {
            final user = await _getOrCreateUser(data.session!.user);
            if (!completer.isCompleted) completer.complete(user);
          } catch (e) {
            if (!completer.isCompleted) completer.completeError(e);
          }
        }
      });

      // 3. Timeout de seguridad (por si el usuario cancela o hay error)
      // 60 segundos debería ser suficiente para loguearse
      Future.delayed(const Duration(seconds: 60), () {
        if (!completer.isCompleted) {
          subscription?.cancel();
          completer.completeError(Exception('Tiempo de espera agotado. Inténtalo de nuevo.'));
        }
      });

      return completer.future;

    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Login con Microsoft
  Future<app_user.User> signInWithMicrosoft() async {
    if (_supabase == null) {
      throw Exception('Supabase no está configurado');
    }
    
    try {
      debugPrint('🔐 Iniciando Microsoft Sign-In...');
      
      // 1. Iniciar el flujo de OAuth
      final response = await _supabase!.auth.signInWithOAuth(
        OAuthProvider.azure,
        redirectTo: SupabaseConfig.redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
        scopes: 'openid profile email offline_access', // Scopes típicos para Microsoft
      );

      if (!response) {
        throw Exception('Error al iniciar sesión con Microsoft');
      }

      // 2. Esperar a que el usuario complete el login y Supabase notifique el evento
      debugPrint('🔐 Esperando autenticación de Microsoft...');
      
      final completer = Completer<app_user.User>();
      StreamSubscription? subscription;

      subscription = _supabase!.auth.onAuthStateChange.listen((data) async {
        // A veces el evento signedIn llega múltiples veces
        if (data.event == AuthChangeEvent.signedIn && data.session != null) {
          debugPrint('✅ Evento de Login recibido (Microsoft)!');
          subscription?.cancel();
          try {
            // Verificar que el proveedor sea azure (opcional, pero buena práctica si se mezcla)
            // No es estrictamente necesario ya que acabamos de pedir azure.
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
      debugPrint('❌ Error de autenticación Microsoft: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Error inesperado Microsoft: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _googleSignIn.signOut();
    if (_supabase != null) {
      await _supabase!.auth.signOut();
    }
  }

  // Obtener o crear usuario en base de datos local
  Future<app_user.User> _getOrCreateUser(User supabaseUser) async {
    // Buscar usuario existente
    final existingUser = await _dbService.getUser(supabaseUser.id);
    if (existingUser != null) {
      return existingUser;
    }

    // Crear nuevo usuario
    final metadata = supabaseUser.userMetadata ?? {};
    final fullName = metadata['full_name'] as String? ?? 
                     metadata['name'] as String? ?? '';
    final nameParts = fullName.split(' ');
    final name = nameParts.isNotEmpty ? nameParts.first : '';
    final surname = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final user = app_user.User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: name,
      surname: surname,
      profilePhotoPath: metadata['avatar_url'] as String? ?? 
                        metadata['picture'] as String?,
      createdAt: DateTime.now(),
    );

    await _dbService.insertUser(user);
    return user;
  }

  // Obtener usuario actual desde base de datos local
  Future<app_user.User?> getCurrentUser() async {
    final uid = currentUserId;
    if (uid == null) return null;

    return await _dbService.getUser(uid);
  }

  // Actualizar perfil
  Future<void> updateProfile(app_user.User user) async {
    await _dbService.updateUser(user);
  }

  // Manejar excepciones de Supabase Auth
  Exception _handleAuthException(AuthException e) {
    final message = e.message.toLowerCase();
    
    if (message.contains('user not found') || message.contains('invalid login')) {
      return Exception('Correo o contraseña incorrectos');
    }
    if (message.contains('email already')) {
      return Exception('El correo ya está registrado');
    }
    if (message.contains('weak password') || message.contains('password')) {
      return Exception('La contraseña debe tener al menos 6 caracteres');
    }
    if (message.contains('invalid email')) {
      return Exception('Correo electrónico no válido');
    }
    
    return Exception(e.message);
  }
}
