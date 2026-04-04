// PLANTILLA DE SECRETOS — SÍ está en control de versiones.
// CÓMO USAR: Copia este archivo como 'secrets.dart' y rellena los valores reales.
// El archivo 'secrets.dart' está en .gitignore y nunca debe subirse a Git.

class AppSecrets {
  // Supabase — obtén estos valores en: https://app.supabase.com → Settings → API
  static const String supabaseUrl = 'https://TU_ID.supabase.co';
  static const String supabaseAnonKey = 'TU_ANON_KEY_AQUI';

  // Google OAuth — obtén estos valores en: https://console.cloud.google.com → Credentials
  static const String googleWebClientId = 'TU_WEB_CLIENT_ID.apps.googleusercontent.com';
  static const String googleAndroidClientId = 'TU_ANDROID_CLIENT_ID.apps.googleusercontent.com';
}
