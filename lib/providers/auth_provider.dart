import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:nachos_pet_care_flutter/models/user.dart';
import 'package:nachos_pet_care_flutter/services/auth_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';


class AuthProvider extends ChangeNotifier {
  final AuthService _authService = getIt<AuthService>();
  StreamSubscription? _authSub;

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _authService.isLoggedIn;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    // Cargar usuario si ya hay sesión activa (p.ej. sesión persistida en disco)
    if (_authService.isLoggedIn) {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    }

    // Escuchar cambios de sesión de Supabase en tiempo real
    _authSub = _authService.authStateChanges.listen((authState) async {
      switch (authState.event) {
        case AuthChangeEvent.signedIn:
          _user = await _authService.getCurrentUser();
          notifyListeners();
          break;
        case AuthChangeEvent.signedOut:
          _user = null;
          notifyListeners();
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String surname,
    String? address,
    String? postalCode,
    String? city,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
        surname: surname,
        address: address,
        postalCode: postalCode,
        city: city,
        phone: phone,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signInWithGoogle();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithMicrosoft() async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signInWithMicrosoft();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile(User updatedUser) async {
    await _authService.updateProfile(updatedUser);
    _user = updatedUser;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
