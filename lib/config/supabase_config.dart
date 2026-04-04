import 'package:nachos_pet_care_flutter/config/secrets.dart';

/// Configuración de Supabase.
/// Las credenciales se obtienen de [AppSecrets] (ver secrets.dart, excluido de git).
class SupabaseConfig {
  static String get supabaseUrl => AppSecrets.supabaseUrl;
  static String get supabaseAnonKey => AppSecrets.supabaseAnonKey;

  // OAuth
  static String get googleWebClientId => AppSecrets.googleWebClientId;
  static String get googleAndroidClientId => AppSecrets.googleAndroidClientId;

  static const String redirectUrl = 'io.supabase.nachospetcare://login-callback';
}
