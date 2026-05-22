// lib/config/secrets.dart
// ⚠️ IMPORTANTE: Este archivo NO debe ser commiteado
// Usa variables de entorno en producción

class AppSecrets {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String googleWebClientId = 'YOUR_GOOGLE_WEB_CLIENT_ID';
  static const String googleAndroidClientId = 'YOUR_GOOGLE_ANDROID_CLIENT_ID';
}

final appSecrets = AppSecrets();
