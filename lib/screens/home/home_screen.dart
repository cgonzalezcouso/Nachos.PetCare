import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nachos_pet_care_flutter/providers/auth_provider.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';
import 'package:nachos_pet_care_flutter/providers/subscription_provider.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/models/vaccine_reminder.dart';
import 'package:nachos_pet_care_flutter/l10n/app_strings.dart';
import 'package:nachos_pet_care_flutter/services/fcm_service.dart';
import 'package:nachos_pet_care_flutter/services/chat_service.dart';
import 'package:nachos_pet_care_flutter/services/wearable_service.dart';
import 'package:nachos_pet_care_flutter/models/wearable_device.dart';
import 'package:nachos_pet_care_flutter/screens/home/marketplace_screen.dart';

void _navigateToAddPet(BuildContext context) {
  final subProvider = context.read<SubscriptionProvider>();
  final petProvider = context.read<PetProvider>();
  if (!subProvider.canAddPet(petProvider.pets.length)) {
    context.push('/premium-paywall');
  } else {
    context.push('/pets/add');
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FCMService.requestPermissionsAndSync();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final petProvider = context.read<PetProvider>();

    if (authProvider.user != null) {
      await petProvider.loadPets(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NachosPetCare'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 4.0),
            child: StreamBuilder<int>(
              stream: getIt<ChatService>().getUnreadCountStream(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                return Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () => context.push('/chats'),
                    tooltip: 'Mensajes',
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(onSwitchTab: (i) => setState(() => _currentIndex = i)),
          const _PetsTab(),
          const MarketplaceScreen(),
          const _RemindersTab(),
          const _MoreTab(),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => _navigateToAddPet(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Tienda',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Recordatorios',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'Más',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final void Function(int) onSwitchTab;

  const _HomeTab({required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PetProvider>(
      builder: (context, auth, petProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage: auth.user?.profilePhotoPath != null && 
                                auth.user!.profilePhotoPath!.isNotEmpty
                            ? NetworkImage(auth.user!.profilePhotoPath!)
                            : null,
                        child: auth.user?.profilePhotoPath == null || 
                                auth.user!.profilePhotoPath!.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 30,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Hola, ${auth.user?.name ?? 'Usuario'}!',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Bienvenido a NachosPetCare',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mascota prioritaria y próximo evento de salud
              const _PriorityPetHealthWidget(),
              const SizedBox(height: 24),

              // Collar Inteligente / Wearable
              const _HomeWearableDashboardCard(),
              const SizedBox(height: 24),

              // Promoción Asistente IA
              const _HomeAiAssistantPromoCard(),
              const SizedBox(height: 24),

              // Quick actions
              Text(
                'Acciones rápidas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.pets,
                      label: 'Mis mascotas',
                      onTap: () => context.push('/pets'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.medical_services,
                      label: 'Veterinario',
                      onTap: () => context.push('/directory'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.vaccines,
                      label: 'Vacunas',
                      onTap: () {
                        final pets = petProvider.pets;
                        if (pets.isNotEmpty) {
                          context.push(
                            '/pets/\${pets.first.id}/vaccines'
                            '?name=\${Uri.encodeComponent(pets.first.name)}',
                          );
                        } else {
                          context.push('/pets');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.calendar_today,
                      label: 'Citas',
                      onTap: () => onSwitchTab(3), // pestaña Recordatorios
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PriorityPetHealthWidget extends StatefulWidget {
  const _PriorityPetHealthWidget();

  @override
  State<_PriorityPetHealthWidget> createState() => _PriorityPetHealthWidgetState();
}

class _PriorityPetHealthWidgetState extends State<_PriorityPetHealthWidget> {
  final DatabaseService _db = getIt<DatabaseService>();

  ImageProvider? _getPetImageProvider(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return null;
    if (photoPath.startsWith('http')) {
      return NetworkImage(photoPath);
    }
    return FileImage(File(photoPath));
  }

  String _getCountdownText(BuildContext context, DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;
    final strings = AppStrings.of(context);

    if (difference == 0) {
      return strings.today.toUpperCase();
    } else if (difference == 1) {
      return strings.oneDayRemaining.toUpperCase();
    } else if (difference < 0) {
      return 'RETRASADO'.toUpperCase();
    } else {
      return 'FALTAN $difference ${strings.daysRemaining.split(' ').first.toUpperCase()}';
    }
  }

  Color _getBadgeColor(BuildContext context, DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;
    final colorScheme = Theme.of(context).colorScheme;

    if (difference == 0) {
      return Colors.redAccent;
    } else if (difference == 1) {
      return Colors.orangeAccent;
    } else if (difference < 0) {
      return Colors.red;
    } else {
      return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final petProvider = context.watch<PetProvider>();
    final strings = AppStrings.of(context);

    if (petProvider.isLoading) {
      return Card(
        child: Container(
          height: 120,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    final pets = petProvider.pets;
    if (pets.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
        ),
        child: InkWell(
          onTap: () => _navigateToAddPet(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.priorityPet,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.noPetsText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Mascota prioritaria: la primera registrada
    final priorityPetObj = pets.first;

    return FutureBuilder<List<VaccineReminder>>(
      future: _db.getVaccineRemindersByPet(priorityPetObj.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: 120,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        }

        final activeReminders = (snapshot.data ?? [])
            .where((r) => !r.completed)
            .toList();

        if (activeReminders.isEmpty) {
          // Todo al día para esta mascota
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant, width: 1),
            ),
            child: InkWell(
              onTap: () => context.push(
                '/pets/${priorityPetObj.id}/vaccines'
                '?name=${Uri.encodeComponent(priorityPetObj.name)}',
              ),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: _getPetImageProvider(priorityPetObj.photoPath),
                      child: priorityPetObj.photoPath == null || priorityPetObj.photoPath!.isEmpty
                          ? Icon(Icons.pets, size: 28, color: colorScheme.primary)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            priorityPetObj.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            strings.noUpcomingEvents,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Ordenar por fecha y tomar la más cercana
        activeReminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        final nextEvent = activeReminders.first;
        final countdownText = _getCountdownText(context, nextEvent.dueDate);
        final badgeColor = _getBadgeColor(context, nextEvent.dueDate);
        final formattedDate = DateFormat('dd/MM/yyyy').format(nextEvent.dueDate);

        return Card(
          elevation: 4,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.primaryContainer.withValues(alpha: 0.15),
                ],
              ),
            ),
            child: InkWell(
              onTap: () => context.push(
                '/pets/${priorityPetObj.id}/vaccines'
                '?name=${Uri.encodeComponent(priorityPetObj.name)}',
              ),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              strings.priorityPet.toUpperCase(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            countdownText,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: _getPetImageProvider(priorityPetObj.photoPath),
                          child: priorityPetObj.photoPath == null || priorityPetObj.photoPath!.isEmpty
                              ? Icon(Icons.pets, size: 28, color: colorScheme.primary)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                priorityPetObj.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.vaccines_outlined,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${strings.vaccine}: ${nextEvent.vaccineName}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_outlined,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formattedDate,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetsTab extends StatelessWidget {
  const _PetsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, _) {
        if (petProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (petProvider.pets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No tienes mascotas registradas',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _navigateToAddPet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir mascota'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: petProvider.pets.length,
          itemBuilder: (context, index) {
            final pet = petProvider.pets[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: pet.photoPath != null && pet.photoPath!.isNotEmpty
                      ? NetworkImage(pet.photoPath!)
                      : null,
                  child: pet.photoPath == null || pet.photoPath!.isEmpty
                      ? Icon(
                          Icons.pets,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                title: Text(pet.name),
                subtitle: Text(pet.typeDisplayName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/pets/${pet.id}'),
              ),
            );
          },
        );
      },
    );
  }
}

class _RemindersTab extends StatelessWidget {
  const _RemindersTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay recordatorios pendientes',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _MoreTab extends StatelessWidget {
  const _MoreTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Comunidad',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _MenuCard(
          icon: Icons.pets,
          title: 'Animales en Adopción',
          subtitle: 'Encuentra tu nuevo compañero',
          color: Colors.orange,
          onTap: () => context.push('/adoption'),
        ),
        const SizedBox(height: 12),
        _MenuCard(
          icon: Icons.article,
          title: 'Artículos sobre Adopción',
          subtitle: 'Aprende sobre adopción responsable',
          color: Colors.blue,
          onTap: () => context.push('/articles'),
        ),
        const SizedBox(height: 12),
        _MenuCard(
          icon: Icons.people_outline,
          title: 'Red Social de Mascotas',
          subtitle: 'Sigue a tus amigos y comenta sus fotos',
          color: Colors.purple,
          onTap: () => context.push('/social'),
        ),
        const SizedBox(height: 24),
        Text(
          'Directorio de Profesionales',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _MenuCard(
          icon: Icons.business,
          title: 'Directorio',
          subtitle: 'Veterinarios, adiestradores, peluqueros y más',
          color: Colors.green,
          onTap: () => context.push('/directory'),
        ),
        const SizedBox(height: 24),
        Text(
          'Dispositivos y GPS',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _MenuCard(
          icon: Icons.map_outlined,
          title: 'Seguimiento GPS',
          subtitle: 'Rastrea la ubicación de tu mascota en tiempo real',
          color: Colors.red,
          onTap: () => context.push('/wearables/gps-tracking'),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeWearableDashboardCard extends StatefulWidget {
  const _HomeWearableDashboardCard();

  @override
  State<_HomeWearableDashboardCard> createState() => _HomeWearableDashboardCardState();
}

class _HomeWearableDashboardCardState extends State<_HomeWearableDashboardCard> {
  final WearableService _wearableService = getIt<WearableService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final petProvider = context.watch<PetProvider>();

    if (petProvider.pets.isEmpty) return const SizedBox.shrink();
    final petName = petProvider.pets.first.name;

    return StreamBuilder<WearableDevice?>(
      stream: _wearableService.deviceStream,
      initialData: _wearableService.currentDevice,
      builder: (context, deviceSnapshot) {
        final device = deviceSnapshot.data;

        if (device == null) {
          // Estado: No emparejado
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
            ),
            child: InkWell(
              onTap: () => context.push('/settings/wearables'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.watch_rounded,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Collar Inteligente',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Vincular GPS o sensor de actividad para $petName.',
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Estado: Dispositivo Conectado
        return StreamBuilder<WearableActivity?>(
          stream: _wearableService.activityStream,
          initialData: _wearableService.currentActivity,
          builder: (context, activitySnapshot) {
            final act = activitySnapshot.data;
            if (act == null) return const SizedBox.shrink();

            return Card(
              elevation: 3,
              shadowColor: colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.surface,
                      colorScheme.primaryContainer.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: InkWell(
                  onTap: () => context.push('/wearables/gps-tracking', extra: petProvider.pets.first),
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.watch_rounded, color: colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  device.name.toUpperCase(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (device.batteryLevel > 20 ? Colors.green : Colors.red).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.battery_std,
                                    size: 12,
                                    color: device.batteryLevel > 20 ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${device.batteryLevel}%',
                                    style: TextStyle(
                                      color: device.batteryLevel > 20 ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Pasos
                            Row(
                              children: [
                                Icon(Icons.directions_run_rounded, color: colorScheme.primary, size: 22),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('PASOS', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                                    Text(
                                      '${act.steps}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Ritmo Cardíaco Animado
                            Row(
                              children: [
                                _HomeHeartBeat(bpm: act.heartRateBpm),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('PULSO', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '${act.heartRateBpm}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
                                        ),
                                        const SizedBox(width: 2),
                                        const Text('bpm', style: TextStyle(color: Colors.grey, fontSize: 9)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Indicador de estado
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HomeHeartBeat extends StatefulWidget {
  final int bpm;
  const _HomeHeartBeat({required this.bpm});

  @override
  State<_HomeHeartBeat> createState() => _HomeHeartBeatState();
}

class _HomeHeartBeatState extends State<_HomeHeartBeat> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: _calculateDuration(widget.bpm),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _HomeHeartBeat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bpm != widget.bpm) {
      _pulseController.duration = _calculateDuration(widget.bpm);
      _pulseController.repeat(reverse: true);
    }
  }

  Duration _calculateDuration(int bpm) {
    final ms = (60000 / bpm) / 2;
    return Duration(milliseconds: ms.round());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.15);
        return Transform.scale(
          scale: scale,
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.red,
            size: 22,
          ),
        );
      },
    );
  }
}

class _HomeAiAssistantPromoCard extends StatelessWidget {
  const _HomeAiAssistantPromoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);

    return Card(
      elevation: 2,
      shadowColor: colorScheme.secondary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: () => context.push('/settings/ai-assistant'),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          strings.aiAssistantTitle.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PRO 24/7',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Análisis de síntomas clínicos y sugerencia de diagnósticos.',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
