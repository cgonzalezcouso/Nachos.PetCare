import 'package:flutter/foundation.dart';

/// Logger de seguridad para la aplicación.
///
/// Proporciona logging condicional que:
/// - En DEBUG: imprime normalmente con [debugPrint].
/// - En RELEASE/PROFILE: suprime todos los mensajes para evitar filtrar
///   información sensible en los logs del sistema (visible con adb logcat).
///
/// Uso:
/// ```dart
/// AppLogger.debug('Usuario autenticado: ${user.email}');
/// AppLogger.error('Error en auth', error: e);
/// AppLogger.info('Ruta cargada');
/// ```
class AppLogger {
  AppLogger._();

  /// Log de información general. Solo visible en modo debug.
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️  [INFO] $message');
    }
  }

  /// Log de depuración detallado. Solo visible en modo debug.
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('🐛 [DEBUG] $message');
    }
  }

  /// Log de advertencia. Solo visible en modo debug.
  static void warn(String message) {
    if (kDebugMode) {
      debugPrint('⚠️  [WARN] $message');
    }
  }

  /// Log de error. Imprime el mensaje genérico siempre; los detalles,
  /// solo en modo debug.
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('❌ [ERROR] $message');
      if (error != null) debugPrint('   Error: $error');
      if (stackTrace != null) debugPrint('   StackTrace: $stackTrace');
    }
  }

  /// Log de autenticación — especialmente sensible.
  /// Solo visible en modo debug.
  static void auth(String message) {
    if (kDebugMode) {
      debugPrint('🔐 [AUTH] $message');
    }
  }

  /// Log de base de datos. Solo visible en modo debug.
  static void db(String message) {
    if (kDebugMode) {
      debugPrint('🗄️  [DB] $message');
    }
  }
}
