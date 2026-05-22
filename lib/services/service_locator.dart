import 'package:get_it/get_it.dart';
import 'package:nachos_pet_care_flutter/services/auth_service.dart';
import 'package:nachos_pet_care_flutter/services/adoption_service.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/storage_service.dart';
import 'package:nachos_pet_care_flutter/services/notification_service.dart';
import 'package:nachos_pet_care_flutter/services/subscription_service.dart';
import 'package:nachos_pet_care_flutter/services/social_service.dart';
import 'package:nachos_pet_care_flutter/services/chat_service.dart';
import 'package:nachos_pet_care_flutter/services/vet_clinic_service.dart';
import 'package:nachos_pet_care_flutter/services/wearable_service.dart';
import 'package:nachos_pet_care_flutter/services/ai_assistant_service.dart';
import 'package:nachos_pet_care_flutter/services/marketplace_service.dart';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';
import 'package:flutter/foundation.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  try {
    getIt.registerLazySingleton<StorageService>(() => StorageService());
    getIt.registerLazySingleton<AuthService>(() => AuthService());
    getIt.registerLazySingleton<AdoptionService>(() => AdoptionService());
    getIt.registerLazySingleton<NotificationService>(() => NotificationService());
    getIt.registerLazySingleton<SubscriptionService>(() => SubscriptionService());
    getIt.registerLazySingleton<SocialService>(() => SocialService());
    getIt.registerLazySingleton<ChatService>(() => ChatService());
    getIt.registerLazySingleton<VetClinicService>(() => VetClinicService());
    getIt.registerLazySingleton<WearableService>(() => WearableService());
    getIt.registerLazySingleton<AiAssistantService>(() => AiAssistantService());
    getIt.registerLazySingleton<MarketplaceService>(() => MarketplaceService());
    
    final databaseService = DatabaseService();
    getIt.registerSingleton<DatabaseService>(databaseService);
    if (!kIsWeb) {
      AppLogger.info('Inicializando base de datos local...');
      await databaseService.initialize();
    } else {
      AppLogger.info('Web: base de datos local inicializada en memoria');
      await databaseService.initialize();
    }
  } catch (e) {
    AppLogger.error('Error en setupServiceLocator', error: e);
  }
}
