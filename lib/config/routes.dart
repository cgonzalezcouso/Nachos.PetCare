import 'package:go_router/go_router.dart';
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
import 'package:nachos_pet_care_flutter/screens/articles/articles_list_screen.dart';
import 'package:nachos_pet_care_flutter/screens/directory/professionals_directory_screen.dart';
import 'package:nachos_pet_care_flutter/screens/settings/settings_screen.dart';
import 'package:nachos_pet_care_flutter/screens/settings/help_support_screen.dart';
import 'package:nachos_pet_care_flutter/screens/pets/vaccines_screen.dart';
import 'package:nachos_pet_care_flutter/screens/pets/vet_history_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
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
  ],
);
