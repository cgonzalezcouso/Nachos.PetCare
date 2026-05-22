import 'package:flutter/foundation.dart';
import 'package:nachos_pet_care_flutter/services/subscription_service.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subService = getIt<SubscriptionService>();
  final DatabaseService _dbService = getIt<DatabaseService>();

  bool _isPremium = false;
  bool _isLoading = false;
  String? _error;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Límites del Plan Gratuito
  int get maxFreePets => 2;
  int get maxFreeEvents => 50;

  SubscriptionProvider() {
    _init();
  }

  Future<void> _init() async {
    await refreshPremiumStatus();
  }

  // Inicializar o re-inicializar el servicio con el ID de usuario actual
  Future<void> initializeForUser(String? userId) async {
    _setLoading(true);
    try {
      await _subService.initialize(userId);
      await refreshPremiumStatus();
    } catch (e) {
      AppLogger.error('Error al inicializar SubscriptionProvider para el usuario: $userId', error: e);
    } finally {
      _setLoading(false);
    }
  }

  // Refrescar el estado de la suscripción leyendo del SDK o almacenamiento local
  Future<void> refreshPremiumStatus() async {
    try {
      final active = await _subService.isPremiumActive();
      if (_isPremium != active) {
        _isPremium = active;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error al refrescar estado de Premium', error: e);
    }
  }

  // Comprobar si el usuario puede añadir una mascota nueva
  bool canAddPet(int currentPetCount) {
    if (_isPremium) return true;
    return currentPetCount < maxFreePets;
  }

  // Comprobar si el usuario puede añadir un evento histórico a una mascota
  Future<bool> canAddEvent(String petId) async {
    if (_isPremium) return true;
    
    // Obtener la cantidad acumulada de eventos en la base de datos local
    final currentCount = await _dbService.getPetEventCount(petId);
    return currentCount < maxFreeEvents;
  }

  // Comprar el Plan Premium (Redirige a Stripe Checkout)
  Future<bool> subscribe() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _subService.purchasePremium();
      if (success) {
        AppLogger.info('Redirección a Stripe Checkout iniciada con éxito.');
        return true;
      } else {
        _setError('No se pudo abrir Stripe Checkout.');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Gestionar la suscripción a través de Stripe Customer Portal
  Future<bool> manageSubscription() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _subService.manageSubscription();
      if (success) {
        AppLogger.info('Redirección a Stripe Customer Portal iniciada con éxito.');
        return true;
      } else {
        _setError('No se pudo abrir el portal de facturación de Stripe.');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Restaurar compras / Confirmar suscripción localmente
  Future<bool> restorePurchases() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _subService.restorePurchases();
      if (success) {
        _isPremium = true;
        notifyListeners();
        AppLogger.info('Suscripción activada/restaurada correctamente.');
        return true;
      } else {
        _setError('No se pudo restaurar la suscripción.');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Método especial de testing para escritorio/emulación
  Future<void> toggleEmulatedPremium(bool active) async {
    if (_subService.isSupportedPlatform) return;
    
    _setLoading(true);
    try {
      await _subService.toggleEmulatedPremium(active);
      _isPremium = active;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error al alternar Premium emulado en Provider', error: e);
    } finally {
      _setLoading(false);
    }
  }

  // Métodos auxiliares de carga y errores
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
