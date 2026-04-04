import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/config/theme.dart';
import 'package:nachos_pet_care_flutter/config/routes.dart';
import 'package:nachos_pet_care_flutter/config/supabase_config.dart';
import 'package:nachos_pet_care_flutter/providers/auth_provider.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';
import 'package:nachos_pet_care_flutter/providers/adoption_provider.dart';
import 'package:nachos_pet_care_flutter/providers/theme_provider.dart';
import 'package:nachos_pet_care_flutter/services/adoption_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inicializar Supabase solo si está configurado
    if (SupabaseConfig.supabaseUrl.isNotEmpty && 
        !SupabaseConfig.supabaseUrl.contains('TU_SUPABASE')) {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: kDebugMode, // Solo logs en modo debug, nunca en producción
      );
    }
    
    // Configurar inyección de dependencias
    await setupServiceLocator();
    
    runApp(const NachosPetCareApp());
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('Error al inicializar la aplicación: $e');
      debugPrint('StackTrace: $stackTrace');
    }
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error al inicializar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Solo mostramos detalles del error en modo debug
                Text(
                  kDebugMode
                      ? e.toString()
                      : 'Hubo un problema al iniciar la aplicación. Por favor, inténtalo de nuevo.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class NachosPetCareApp extends StatelessWidget {
  const NachosPetCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(
          create: (_) => AdoptionProvider(service: getIt<AdoptionService>()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp.router(
          title: 'NachosPetCare',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
