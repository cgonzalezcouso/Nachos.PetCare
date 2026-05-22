import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/config/theme.dart';
import 'package:nachos_pet_care_flutter/config/routes.dart';
import 'package:nachos_pet_care_flutter/config/supabase_config.dart';
import 'package:nachos_pet_care_flutter/providers/auth_provider.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';
import 'package:nachos_pet_care_flutter/providers/adoption_provider.dart';
import 'package:nachos_pet_care_flutter/providers/theme_provider.dart';
import 'package:nachos_pet_care_flutter/providers/reminder_provider.dart';
import 'package:nachos_pet_care_flutter/providers/locale_provider.dart';
import 'package:nachos_pet_care_flutter/providers/subscription_provider.dart';
import 'package:nachos_pet_care_flutter/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nachos_pet_care_flutter/services/adoption_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/services/fcm_service.dart';
import 'package:nachos_pet_care_flutter/utils/windows_protocol.dart';
import 'package:app_links/app_links.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb && Platform.isWindows) {
    await registerCustomSchemeWindows();
  }
  
  try {
    // Inicializar Supabase
    if (SupabaseConfig.supabaseUrl.isNotEmpty && 
        !SupabaseConfig.supabaseUrl.contains('TU_SUPABASE')) {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: kDebugMode,
      );
    }

    // Escuchar enlaces profundos en Windows para procesar los callbacks de login
    if (!kIsWeb && Platform.isWindows) {
      final appLinks = AppLinks();
      
      // Procesar el enlace de inicio si la app se abrió a través de un link
      try {
        final initialUri = await appLinks.getInitialLink();
        if (initialUri != null) {
          _handleWindowsDeepLink(initialUri);
        }
      } catch (e) {
        debugPrint('Error al obtener el enlace inicial de Windows: $e');
      }

      // Escuchar enlaces mientras la aplicación está en ejecución
      appLinks.uriLinkStream.listen((uri) {
        _handleWindowsDeepLink(uri);
      }, onError: (err) {
        debugPrint('Error en la escucha de enlaces profundos de Windows: $err');
      });
    }
    
    // Configurar inyección de dependencias
    await setupServiceLocator();

    // Inicializar Firebase/FCM
    await FCMService.initialize();
    
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
                Text(
                  e.toString(),
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
        ChangeNotifierProxyProvider<AuthProvider, SubscriptionProvider>(
          create: (_) => SubscriptionProvider(),
          update: (_, auth, sub) {
            final provider = sub ?? SubscriptionProvider();
            provider.initializeForUser(auth.user?.id);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(
          create: (_) => AdoptionProvider(service: getIt<AdoptionService>()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => Consumer<LocaleProvider>(
          builder: (context, localeProvider, _) => MaterialApp.router(
            title: 'NachosPetCare',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: appRouter,
          ),
        ),
      ),
    );
  }
}

void _handleWindowsDeepLink(Uri uri) {
  debugPrint('Enlace profundo Windows detectado: $uri');
  if (uri.scheme == 'io.supabase.nachospetcare') {
    try {
      Supabase.instance.client.auth.getSessionFromUrl(uri);
      debugPrint('Callback de sesión procesado con éxito para: $uri');
    } catch (e) {
      debugPrint('Error al procesar el enlace de sesión de Supabase: $e');
    }
  }
}
