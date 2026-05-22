import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nachos_pet_care_flutter/config/stripe_config.dart';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';

class SubscriptionService {
  bool _isInitialized = false;
  bool _isPremiumActive = false;

  // Con Stripe Checkout (web), todas las plataformas son soportadas nativamente abriendo el navegador.
  bool get isSupportedPlatform => true;

  // Inicializar el servicio de suscripción Stripe
  Future<void> initialize(String? userId) async {
    if (_isInitialized) return;

    try {
      AppLogger.info('Inicializando servicio de suscripción Stripe...');
      final prefs = await SharedPreferences.getInstance();
      _isPremiumActive = prefs.getBool('stripe_premium_active') ?? false;
      
      // Si no estaba activa pero existía una emulación previa en SharedPreferences, la migramos
      if (!_isPremiumActive) {
        final emulated = prefs.getBool('emulated_premium_active') ?? false;
        if (emulated) {
          _isPremiumActive = true;
          await prefs.setBool('stripe_premium_active', true);
        }
      }
      
      _isInitialized = true;
      AppLogger.info('Servicio Stripe inicializado. Premium activo localmente: $_isPremiumActive');
    } catch (e, stackTrace) {
      AppLogger.error('Error al inicializar servicio Stripe', error: e, stackTrace: stackTrace);
    }
  }

  // Identificar usuario al iniciar sesión
  Future<void> logIn(String userId) async {
    AppLogger.info('Usuario identificado en Stripe Service: $userId');
    await initialize(userId);
  }

  // Cerrar sesión
  Future<void> logOut() async {
    AppLogger.info('Sesión cerrada en Stripe Service');
  }

  // Verificar si la suscripción Premium está activa
  Future<bool> isPremiumActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremiumActive = prefs.getBool('stripe_premium_active') ?? false;
      return _isPremiumActive;
    } catch (e) {
      AppLogger.error('Error al leer estado de suscripción Stripe', error: e);
      return _isPremiumActive;
    }
  }

  // Iniciar flujo de compra de Stripe Checkout (abre el enlace de pago en el navegador)
  Future<bool> purchasePremium() async {
    try {
      final url = Uri.parse(StripeConfig.subscriptionPaymentLink);
      AppLogger.info('Redirigiendo a Stripe Checkout: $url');
      
      if (await canLaunchUrl(url)) {
        final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        if (launched) {
          AppLogger.info('Stripe Checkout abierto con éxito.');
          return true;
        }
      }
      AppLogger.warn('No se pudo abrir la URL de Stripe Checkout: $url');
      return false;
    } catch (e) {
      AppLogger.error('Error al abrir Stripe Checkout', error: e);
      return false;
    }
  }

  // Redirigir al usuario al Stripe Customer Portal para gestionar su suscripción (ej: cancelar)
  Future<bool> manageSubscription() async {
    try {
      final url = Uri.parse(StripeConfig.billingPortalLink);
      AppLogger.info('Redirigiendo a Stripe Customer Portal: $url');
      
      if (await canLaunchUrl(url)) {
        final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        if (launched) {
          AppLogger.info('Stripe Customer Portal abierto con éxito.');
          return true;
        }
      }
      AppLogger.warn('No se pudo abrir la URL de Stripe Customer Portal: $url');
      return false;
    } catch (e) {
      AppLogger.error('Error al abrir Stripe Customer Portal', error: e);
      return false;
    }
  }

  // Restaurar compras anteriores (simulación de restauración en local)
  Future<bool> restorePurchases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('stripe_premium_active', true);
      _isPremiumActive = true;
      AppLogger.info('Suscripción Stripe restaurada localmente.');
      return true;
    } catch (e) {
      AppLogger.error('Error al restaurar suscripción Stripe', error: e);
      return false;
    }
  }

  // Cambiar manualmente el estado Premium (método de simulación para pruebas)
  Future<void> toggleEmulatedPremium(bool active) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('stripe_premium_active', active);
      await prefs.setBool('emulated_premium_active', active);
      _isPremiumActive = active;
      AppLogger.info('Suscripción (Simulada): Estado Premium cambiado a: $active.');
    } catch (e) {
      AppLogger.error('Error al alternar estado Premium emulado', error: e);
    }
  }
}
