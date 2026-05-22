// lib/config/secrets.dart
// ⚠️ IMPORTANTE: Este archivo NO debe ser commiteado
// Usa variables de entorno en producción

class AppSecrets {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}

final appSecrets = AppSecrets();
