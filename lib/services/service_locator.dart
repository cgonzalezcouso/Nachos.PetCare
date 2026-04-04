import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:nachos_pet_care_flutter/services/auth_service.dart';
import 'package:nachos_pet_care_flutter/services/adoption_service.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/storage_service.dart';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  try {
    // Registrar servicios
    AppLogger.info('Registrando servicios...');
    getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
    getIt.registerLazySingleton<StorageService>(() => StorageService());
    getIt.registerLazySingleton<AuthService>(() => AuthService());
    getIt.registerLazySingleton<AdoptionService>(() => AdoptionService());
    
    if (!kIsWeb) {
      AppLogger.info('Inicializando base de datos local...');
      await getIt<DatabaseService>().initialize();
    } else {
      AppLogger.info('Web: base de datos local omitida (se usa Supabase)');
    }
    
    AppLogger.info('Servicios inicializados correctamente');
  } catch (e, stackTrace) {
    AppLogger.error('Error al configurar servicios', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
