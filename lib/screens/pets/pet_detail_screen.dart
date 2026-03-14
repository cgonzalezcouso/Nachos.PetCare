import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:intl/intl.dart';

class PetDetailScreen extends StatelessWidget {
  final String petId;

  const PetDetailScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, _) {
        final pet = petProvider.pets.firstWhere(
          (p) => p.id == petId,
          orElse: () => Pet(
            id: '',
            ownerId: '',
            name: 'No encontrado',
            type: PetType.other,
            createdAt: DateTime.now(),
          ),
        );

        if (pet.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mascota')),
            body: const Center(child: Text('Mascota no encontrada')),
          );
        }

        return Scaffold(
          bottomNavigationBar: NavigationBar(
            selectedIndex: 1, // Mascotas activo
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.go('/home'); // vuelve al home en la pestaña mascotas
                  break;
                case 2:
                  context.go('/home');
                  break;
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.pets),
                selectedIcon: Icon(Icons.pets),
                label: 'Mascotas',
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz),
                selectedIcon: Icon(Icons.more_horiz),
                label: 'Más',
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                // Botón de volver siempre visible
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(pet.name),
                  background: pet.photoPath != null && pet.photoPath!.isNotEmpty
                      ? _PetPhoto(photoPath: pet.photoPath!)
                      : Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.pets,
                            size: 80,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                ),
                actions: [
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.go('/pets/${pet.id}/edit');
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('¿Eliminar mascota?'),
                            content: Text('¿Seguro que quieres eliminar a ${pet.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await petProvider.deletePet(petId);
                          if (context.mounted) {
                            context.go('/home');
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Info card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Divider(),
                            _InfoRow(label: 'Tipo', value: pet.typeDisplayName),
                            if (pet.breed != null && pet.breed!.isNotEmpty)
                              _InfoRow(label: 'Raza', value: pet.breed!),
                            _InfoRow(
                              label: 'Género',
                              value: pet.gender == PetGender.male
                                  ? 'Macho'
                                  : pet.gender == PetGender.female
                                      ? 'Hembra'
                                      : 'Desconocido',
                            ),
                            if (pet.birthDate != null)
                              _InfoRow(
                                label: 'Fecha de nacimiento',
                                value: DateFormat('dd/MM/yyyy').format(pet.birthDate!),
                              ),
                            if (pet.ageInYears != null)
                              _InfoRow(
                                label: 'Edad',
                                value: '${pet.ageInYears} años',
                              ),
                            if (pet.weight != null)
                              _InfoRow(
                                label: 'Peso',
                                value: '${pet.weight} kg',
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes card
                    if (pet.notes != null && pet.notes!.isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notas',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Divider(),
                              Text(pet.notes!),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Quick actions
                    Text(
                      'Acciones',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.vaccines,
                            label: 'Vacunas',
                            onTap: () => context.go(
                              '/pets/${pet.id}/vaccines?name=${Uri.encodeComponent(pet.name)}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.medical_services,
                            label: 'Historial',
                            onTap: () => context.go(
                              '/pets/${pet.id}/history?name=${Uri.encodeComponent(pet.name)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget auxiliar para mostrar la foto (local o red)
class _PetPhoto extends StatelessWidget {
  final String photoPath;
  const _PetPhoto({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    if (photoPath.startsWith('http')) {
      return Image.network(photoPath, fit: BoxFit.cover);
    }
    return Image.file(
      File(photoPath),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(Icons.pets, size: 80, color: Theme.of(context).colorScheme.onPrimaryContainer),
      ),
    );
  }
}


class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
