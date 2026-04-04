import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/models/adoption_pet.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/providers/adoption_provider.dart';

class AdoptionListScreen extends StatefulWidget {
  const AdoptionListScreen({super.key});

  @override
  State<AdoptionListScreen> createState() => _AdoptionListScreenState();
}

class _AdoptionListScreenState extends State<AdoptionListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al entrar (solo si la lista está vacía)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdoptionProvider>();
      if (provider.pets.isEmpty) {
        provider.loadAdoptionPets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdoptionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Animales en Adopción'),
            actions: [
              // Botón de refresh
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar',
                onPressed: provider.isLoading ? null : provider.loadAdoptionPets,
              ),
              // Filtro por tipo
              PopupMenuButton<PetType?>(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filtrar por tipo',
                onSelected: provider.filterByType,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: null,
                    child: Text('Todos'),
                  ),
                  ...PetType.values.map((type) => PopupMenuItem(
                        value: type,
                        child: Text(_getTypeDisplayName(type)),
                      )),
                ],
              ),
            ],
          ),
          body: _buildBody(context, provider),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdoptionProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Error al cargar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: provider.loadAdoptionPets,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final pets = provider.filteredPets;

    if (pets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay animales en adopción',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Revisa más tarde'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        return _AdoptionPetCard(
          pet: pet,
          onTap: () => context.push('/adoption/${pet.id}'),
        );
      },
    );
  }

  String _getTypeDisplayName(PetType type) {
    switch (type) {
      case PetType.dog:        return 'Perro';
      case PetType.cat:        return 'Gato';
      case PetType.rabbit:     return 'Conejo';
      case PetType.rodent:     return 'Roedor';
      case PetType.ferret:     return 'Hurón';
      case PetType.bird:       return 'Ave';
      case PetType.fish:       return 'Pez';
      case PetType.reptile:    return 'Reptil';
      case PetType.amphibian:  return 'Anfibio';
      case PetType.invertebrate: return 'Invertebrado';
      case PetType.farmAnimal: return 'Animal de corral';
      case PetType.other:      return 'Otro';
    }
  }
}

// ─── Tarjeta de animal en adopción ───────────────────────────────────────────

class _AdoptionPetCard extends StatelessWidget {
  final AdoptionPet pet;
  final VoidCallback onTap;

  const _AdoptionPetCard({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen ──────────────────────────────────
            _PetImage(photoUrl: pet.photoUrl),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Urgente badge
                  if (pet.isUrgent) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'URGENTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Nombre
                  Text(pet.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),

                  // Tipo y raza
                  _InfoRow(
                    icon: Icons.pets,
                    text: '${_getTypeDisplayName(pet.type)}'
                        '${pet.breed != null ? ' • ${pet.breed}' : ''}',
                  ),
                  const SizedBox(height: 2),

                  // Edad y género
                  _InfoRow(
                    icon: Icons.cake,
                    text: '${pet.ageDisplay} • ${_getGenderDisplayName(pet.gender)}'
                        ' • ${pet.sizeDisplay}',
                  ),
                  const SizedBox(height: 6),

                  // Chips: vacunado, esterilizado
                  Wrap(
                    spacing: 6,
                    children: [
                      if (pet.vaccinated)
                        _Chip(label: 'Vacunado', color: Colors.green),
                      if (pet.sterilized)
                        _Chip(label: 'Esterilizado', color: Colors.indigo),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  Text(
                    pet.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),

                  // Ubicación y refugio
                  _InfoRow(
                    icon: Icons.location_on,
                    text: '${pet.location} • ${pet.shelterName}',
                    color: theme.colorScheme.secondary,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeDisplayName(PetType type) {
    switch (type) {
      case PetType.dog:        return 'Perro';
      case PetType.cat:        return 'Gato';
      case PetType.rabbit:     return 'Conejo';
      case PetType.rodent:     return 'Roedor';
      case PetType.ferret:     return 'Hurón';
      case PetType.bird:       return 'Ave';
      case PetType.fish:       return 'Pez';
      case PetType.reptile:    return 'Reptil';
      case PetType.amphibian:  return 'Anfibio';
      case PetType.invertebrate: return 'Invertebrado';
      case PetType.farmAnimal: return 'Animal de corral';
      case PetType.other:      return 'Otro';
    }
  }

  String _getGenderDisplayName(PetGender gender) {
    switch (gender) {
      case PetGender.male:    return 'Macho';
      case PetGender.female:  return 'Hembra';
      case PetGender.unknown: return 'Desconocido';
    }
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _PetImage extends StatelessWidget {
  final String? photoUrl;
  const _PetImage({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Image.network(
          photoUrl!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          headers: const {
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
                '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (_, __, ___) => _placeholder(context),
        ),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Center(
        child: Icon(
          Icons.pets,
          size: 80,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final int? maxLines;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.color,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
