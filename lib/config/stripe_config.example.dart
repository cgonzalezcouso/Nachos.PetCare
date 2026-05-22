// PLANTILLA DE CONFIGURACIÓN DE STRIPE — SÍ está en control de versiones.
// CÓMO USAR: Copia este archivo como 'stripe_config.dart' y rellena los valores reales.
// El archivo 'stripe_config.dart' está en .gitignore y nunca debe subirse a Git.

class StripeConfig {
  // Clave pública de Stripe (Publishable Key)
  static const String publishableKey = "TU_STRIPE_PUBLISHABLE_KEY";
  // Reemplaza esto con tu Stripe Payment Link real para la suscripción
  static const String subscriptionPaymentLink = "https://buy.stripe.com/TU_ENLACE_SUSCRIPCION";
  // Reemplaza esto con el enlace de tu Customer Portal de Stripe para que gestionen su plan
  static const String billingPortalLink = "https://billing.stripe.com/p/login/TU_ENLACE_PORTAL";
}
