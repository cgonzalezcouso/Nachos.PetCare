import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nachos_pet_care_flutter/screens/auth/login_screen.dart';
import 'package:nachos_pet_care_flutter/screens/auth/register_screen.dart';
import 'package:nachos_pet_care_flutter/screens/home/home_screen.dart';
import 'package:nachos_pet_care_flutter/screens/pets/pet_list_screen.dart';
import 'package:nachos_pet_care_flutter/screens/pets/pet_detail_screen.dart';
import 'package:nachos_pet_care_flutter/screens/pets/add_pet_screen.dart';
import 'package:nachos_pet_care_flutter/screens/pets/edit_pet_screen.dart';
import 'package:nachos_pet_care_flutter/screens/profile/profile_screen.dart';
import 'package:nachos_pet_care_flutter/screens/profile/edit_profile_screen.dart';
import 'package:nachos_pet_care_flutter/screens/splash_screen.dart';
import 'package:nachos_pet_care_flutter/screens/adoption/adoption_list_screen.dart';
import 'package:nachos_pet_care_flutter/screens/adoption/adoption_detail_screen.dart';
import 'package:nachos_pet_care_flutter/screens/articles/articles_list_screen.dart';
import 'package:nachos_pet_care_flutter/screens/directory/professionals_directory_screen.dart';
import 'package:nachos_pet_care_flutter/screens/settings/settings_screen.dart';
import 'package:nachos_pet_care_flutter/screens/settings/help_support_screen.dart';
import 'package:nachos_pet_care_flutter/screens/pets/vaccines_screen.dart';
import 'package:nachos_pet_care_flutter/screens/pets/vet_history_screen.dart';
import 'package:nachos_pet_care_flutter/screens/pets/pet_gallery_screen.dart';
import 'package:nachos_pet_care_flutter/screens/pets/pet_weight_screen.dart';
import 'package:nachos_pet_care_flutter/screens/settings/premium_paywall_screen.dart';
import 'package:nachos_pet_care_flutter/screens/social/social_feed_screen.dart';
import 'package:nachos_pet_care_flutter/screens/social/public_pet_profile_screen.dart';
import 'package:nachos_pet_care_flutter/screens/chat/chat_list_screen.dart';
import 'package:nachos_pet_care_flutter/screens/chat/chat_detail_screen.dart';
import 'package:nachos_pet_care_flutter/screens/vet/vet_dashboard_screen.dart';
import 'package:nachos_pet_care_flutter/screens/settings/vet_invitations_screen.dart';
import 'package:nachos_pet_care_flutter/screens/settings/privacy_security_screen.dart';
import 'package:nachos_pet_care_flutter/screens/wearables/wearables_screen.dart';
import 'package:nachos_pet_care_flutter/screens/wearables/gps_tracking_screen.dart';
import 'package:nachos_pet_care_flutter/screens/ai_assistant/ai_assistant_screen.dart';
import 'package:nachos_pet_care_flutter/screens/home/product_detail_screen.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';



// Rutas accesibles sin autenticación
const _publicRoutes = {'/login', '/register', '/', '/vet/dashboard'};

// Comprueba si el usuario está autenticado con Supabase
bool _isAuthenticated() {
  try {
    return Supabase.instance.client.auth.currentUser != null;
  } catch (_) {
    return false;
  }
}

// ─── Listenable que re-notifica al router en cada cambio de sesión ────────────
// GoRouter sólo re-evalúa el redirect cuando este Listenable notifica.
// Al escuchar el stream de Supabase, cualquier login/logout dispara la lógica
// del guard inmediatamente, sin race conditions.
class _SupabaseAuthListenable extends ChangeNotifier {
  StreamSubscription<AuthState>? _sub;

  _SupabaseAuthListenable() {
    try {
      _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
        notifyListeners();
      });
    } catch (_) {
      // Supabase no disponible (modo sin conexión / tests)
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final _authListenable = _SupabaseAuthListenable();

final appRouter = GoRouter(
  initialLocation: '/',
  // Reactivo al stream de Supabase: se re-evalúa en cada cambio de sesión
  refreshListenable: _authListenable,
  // Route guard global: ejecutado antes de cada navegación
  redirect: (context, state) {
    final isAuthenticated = _isAuthenticated();
    final path = state.matchedLocation;
    final isPublic = _publicRoutes.contains(path);

    // Usuario no autenticado intentando acceder a ruta privada → login
    if (!isAuthenticated && !isPublic) {
      return '/login';
    }

    // Usuario autenticado intentando ir al login/register → home
    if (isAuthenticated && (path == '/login' || path == '/register')) {
      return '/home';
    }

    // Sin redirección
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/pets',
      builder: (context, state) => const PetListScreen(),
    ),
    GoRoute(
      path: '/pets/add',
      builder: (context, state) => const AddPetScreen(),
    ),
    GoRoute(
      path: '/pets/:id',
      builder: (context, state) {
        final petId = state.pathParameters['id']!;
        return PetDetailScreen(petId: petId);
      },
    ),
    GoRoute(
      path: '/pets/:id/edit',
      builder: (context, state) {
        final petId = state.pathParameters['id']!;
        return EditPetScreen(petId: petId);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/adoption',
      builder: (context, state) => const AdoptionListScreen(),
    ),
    GoRoute(
      path: '/adoption/:id',
      builder: (context, state) {
        final petId = state.pathParameters['id']!;
        return AdoptionDetailScreen(petId: petId);
      },
    ),
    GoRoute(
      path: '/articles',
      builder: (context, state) => const ArticlesListScreen(),
    ),
    GoRoute(
      path: '/directory',
      builder: (context, state) => const ProfessionalsDirectoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/premium-paywall',
      builder: (context, state) => const PremiumPaywallScreen(),
    ),
    GoRoute(
      path: '/pets/:id/vaccines',
      builder: (context, state) {
        final petId = state.pathParameters['id']!;
        final petName = state.uri.queryParameters['name'] ?? '';
        return VaccinesScreen(petId: petId, petName: petName);
      },
    ),
    GoRoute(
      path: '/pets/:id/history',
      builder: (context, state) {
        final petId = state.pathParameters['id']!;
        final petName = state.uri.queryParameters['name'] ?? '';
        return VetHistoryScreen(petId: petId, petName: petName);
      },
    ),
    GoRoute(
      path: '/pets/:id/gallery',
      builder: (context, state) {
        final petId = state.pathParameters['id']!;
        final petName = state.uri.queryParameters['name'] ?? '';
        return PetGalleryScreen(petId: petId, petName: petName);
      },
    ),
    GoRoute(
      path: '/pets/:id/weight',
      builder: (context, state) {
        final petId = state.pathParameters['id']!;
        final petName = state.uri.queryParameters['name'] ?? '';
        return PetWeightScreen(petId: petId, petName: petName);
      },
    ),
    GoRoute(
      path: '/social',
      builder: (context, state) => const SocialFeedScreen(),
    ),
    GoRoute(
      path: '/social/pets/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PublicPetProfileScreen(petId: id);
      },
    ),
    GoRoute(
      path: '/chats',
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/chats/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        final userName = state.uri.queryParameters['name'] ?? '';
        return ChatDetailScreen(userId: userId, userName: userName);
      },
    ),
    GoRoute(
      path: '/vet/dashboard',
      builder: (context, state) => const VetDashboardScreen(),
    ),
    GoRoute(
      path: '/settings/vet-invitations',
      builder: (context, state) => const VetInvitationsScreen(),
    ),
    GoRoute(
      path: '/settings/wearables',
      builder: (context, state) => const WearablesScreen(),
    ),
    GoRoute(
      path: '/settings/ai-assistant',
      builder: (context, state) => const AiAssistantScreen(),
    ),
    GoRoute(
      path: '/settings/privacy-security',
      builder: (context, state) => const PrivacySecurityScreen(),
    ),
    GoRoute(
      path: '/wearables/gps-tracking',
      builder: (context, state) {
        final initialPet = state.extra as Pet?;
        return GpsTrackingScreen(initialPet: initialPet);
      },
    ),
    GoRoute(
      path: '/marketplace/product/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        final selectedPet = state.extra as Pet?;
        return ProductDetailScreen(
          productId: productId,
          selectedPet: selectedPet,
        );
      },
    ),
  ],
);



