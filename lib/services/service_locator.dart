import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:nachos_pet_care_flutter/services/auth_service.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/storage_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  try {
    // Registrar servicios
    debugPrint('📦 Registrando servicios...');
    getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
    getIt.registerLazySingleton<StorageService>(() => StorageService());
    getIt.registerLazySingleton<AuthService>(() => AuthService());
    
    debugPrint('💾 Inicializando base de datos local...');
    // Inicializar base de datos local
    await getIt<DatabaseService>().initialize();
    
    debugPrint('✅ Servicios inicializados correctamente');
  } catch (e, stackTrace) {
    debugPrint('❌ Error al configurar servicios: $e');
    debugPrint('StackTrace: $stackTrace');
    rethrow;
  }
}
