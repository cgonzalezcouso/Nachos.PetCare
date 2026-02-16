import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile header
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: user?.profilePhotoPath != null && 
                          user!.profilePhotoPath!.isNotEmpty
                      ? NetworkImage(user.profilePhotoPath!)
                      : null,
                  child: user?.profilePhotoPath == null || 
                          user!.profilePhotoPath!.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'Usuario',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),

                // Info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _ProfileItem(
                          icon: Icons.person,
                          label: 'Nombre',
                          value: user?.name ?? '',
                        ),
                        const Divider(),
                        _ProfileItem(
                          icon: Icons.person_outline,
                          label: 'Apellidos',
                          value: user?.surname ?? '',
                        ),
                        const Divider(),
                        _ProfileItem(
                          icon: Icons.email,
                          label: 'Correo',
                          value: user?.email ?? '',
                        ),
                        if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                          const Divider(),
                          _ProfileItem(
                            icon: Icons.phone,
                            label: 'Teléfono',
                            value: user.phone!,
                          ),
                        ],
                        if (user?.address != null && user!.address!.isNotEmpty) ...[
                          const Divider(),
                          _ProfileItem(
                            icon: Icons.home,
                            label: 'Dirección',
                            value: user.address!,
                          ),
                        ],
                        if (user?.city != null && user!.city!.isNotEmpty) ...[
                          const Divider(),
                          _ProfileItem(
                            icon: Icons.location_city,
                            label: 'Ciudad',
                            value: user.city!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Settings card
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Editar perfil'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          debugPrint('👉 ProfileScreen: "Editar perfil" tapped');
                          try {
                            context.push('/edit-profile');
                            debugPrint('👉 ProfileScreen: Navigation command sent');
                          } catch (e) {
                            debugPrint('❌ ProfileScreen Navigation Error: $e');
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Configuración'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/settings');
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Ayuda'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/help');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await auth.logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
