import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/providers/auth_provider.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';

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
          const _RemindersTab(),
          const _MoreTab(),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => context.push('/pets/add'),
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
                      onTap: () => onSwitchTab(2), // pestaña Recordatorios
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
                  onPressed: () => context.push('/pets/add'),
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
