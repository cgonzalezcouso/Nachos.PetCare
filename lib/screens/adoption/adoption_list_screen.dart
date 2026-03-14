import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nachos_pet_care_flutter/models/adoption_pet.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';

class AdoptionListScreen extends StatefulWidget {
  const AdoptionListScreen({super.key});

  @override
  State<AdoptionListScreen> createState() => _AdoptionListScreenState();
}

class _AdoptionListScreenState extends State<AdoptionListScreen> {
  List<AdoptionPet> _adoptionPets = [];
  bool _isLoading = true;
  PetType? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadAdoptionPets();
  }

  Future<void> _loadAdoptionPets() async {
    // TODO: Cargar desde la base de datos
    // Por ahora, datos de ejemplo
    setState(() {
      _adoptionPets = _getDemoData();
      _isLoading = false;
    });
  }

  List<AdoptionPet> _getDemoData() {
    return [
      AdoptionPet(
        id: '1',
        name: 'Luna',
        type: PetType.dog,
        breed: 'Mestizo',
        ageInMonths: 18,
        gender: PetGender.female,
        description: 'Luna es una perrita muy cariñosa que busca un hogar lleno de amor. Se lleva bien con niños y otros perros.',
        location: 'Madrid',
        contactPhone: '+34 600 123 456',
        contactEmail: 'adopciones@refugio.com',
        shelterName: 'Refugio Esperanza',
        isUrgent: true,
        photoPath: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=600&auto=format&fit=crop',
        createdAt: DateTime.now(),
      ),
      AdoptionPet(
        id: '2',
        name: 'Max',
        type: PetType.cat,
        breed: 'Siamés',
        ageInMonths: 24,
        gender: PetGender.male,
        description: 'Max es un gato tranquilo y juguetón, perfecto para familias. Le encanta el sol y los mimos.',
        location: 'Barcelona',
        contactPhone: '+34 600 789 012',
        contactEmail: 'info@gatunos.org',
        shelterName: 'Asociación Gatunos',
        isUrgent: false,
        photoPath: 'https://images.unsplash.com/photo-1513245543132-31f507417b26?w=600&auto=format&fit=crop',
        createdAt: DateTime.now(),
      ),
      AdoptionPet(
        id: '3',
        name: 'Nube',
        type: PetType.rabbit,
        breed: 'Angora',
        ageInMonths: 8,
        gender: PetGender.female,
        description: 'Nube es una coneja esponjosa y muy curiosa. Está esterilizada y acostumbrada a vivir en interior.',
        location: 'Valencia',
        contactPhone: '+34 611 222 333',
        contactEmail: 'conejos@animalia.org',
        shelterName: 'Animalia Valencia',
        isUrgent: false,
        photoPath: 'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=600&auto=format&fit=crop',
        createdAt: DateTime.now(),
      ),
      AdoptionPet(
        id: '4',
        name: 'Bruno',
        type: PetType.dog,
        breed: 'Labrador',
        ageInMonths: 36,
        gender: PetGender.male,
        description: 'Bruno es un perro enorme con un corazón aún más grande. Ideal para casas con jardín.',
        location: 'Sevilla',
        contactPhone: '+34 622 444 555',
        contactEmail: 'bruno@refugioSur.es',
        shelterName: 'Refugio del Sur',
        isUrgent: true,
        photoPath: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=600&auto=format&fit=crop',
        createdAt: DateTime.now(),
      ),
      AdoptionPet(
        id: '5',
        name: 'Kira',
        type: PetType.cat,
        breed: 'Común europeo',
        ageInMonths: 12,
        gender: PetGender.female,
        description: 'Kira llegó al refugio siendo muy pequeña. Es independiente pero muy cariñosa cuando te conoce.',
        location: 'Bilbao',
        contactPhone: '+34 633 555 666',
        contactEmail: 'kira@gatos-norte.org',
        shelterName: 'Gatos del Norte',
        isUrgent: false,
        photoPath: 'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=600&auto=format&fit=crop',
        createdAt: DateTime.now(),
      ),
      AdoptionPet(
        id: '6',
        name: 'Pico',
        type: PetType.bird,
        breed: 'Periquito',
        ageInMonths: 6,
        gender: PetGender.male,
        description: 'Pico es un periquito alegre y muy parlanchín. Le encanta escuchar música y aprender palabras nuevas.',
        location: 'Zaragoza',
        contactPhone: '+34 644 666 777',
        contactEmail: 'aves@naturalia.es',
        shelterName: 'Naturalia Zaragoza',
        isUrgent: false,
        photoPath: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=600&auto=format&fit=crop',
        createdAt: DateTime.now(),
      ),
    ];
  }


  List<AdoptionPet> get _filteredPets {
    if (_selectedType == null) return _adoptionPets;
    return _adoptionPets.where((pet) => pet.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animales en Adopción'),
        actions: [
          PopupMenuButton<PetType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) {
              setState(() {
                _selectedType = type;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todos'),
              ),
              ...PetType.values.map((type) {
                final pet = AdoptionPet(
                  id: '',
                  name: '',
                  type: type,
                  gender: PetGender.unknown,
                  description: '',
                  location: '',
                  contactPhone: '',
                  contactEmail: '',
                  shelterName: '',
                  createdAt: DateTime.now(),
                );
                return PopupMenuItem(
                  value: type,
                  child: Text(pet.type.name),
                );
              }),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredPets.isEmpty
              ? Center(
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
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredPets.length,
                  itemBuilder: (context, index) {
                    final pet = _filteredPets[index];
                    return _AdoptionPetCard(
                      pet: pet,
                      onTap: () => context.push('/adoption/${pet.id}'),
                    );
                  },
                ),
    );
  }
}

class _AdoptionPetCard extends StatelessWidget {
  final AdoptionPet pet;
  final VoidCallback onTap;

  const _AdoptionPetCard({
    required this.pet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            if (pet.photoPath != null && pet.photoPath!.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  pet.photoPath!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.pets,
                      size: 80,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    Icons.pets,
                    size: 80,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Urgente badge
                  if (pet.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                  if (pet.isUrgent) const SizedBox(height: 8),

                  // Nombre
                  Text(
                    pet.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),

                  // Tipo y raza
                  Row(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getTypeDisplayName(pet.type)}${pet.breed != null ? ' • ${pet.breed}' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Edad y género
                  Row(
                    children: [
                      Icon(
                        Icons.cake,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pet.ageDisplay} • ${_getGenderDisplayName(pet.gender)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  Text(
                    pet.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),

                  // Ubicación y refugio
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${pet.location} • ${pet.shelterName}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
      case PetType.dog:
        return 'Perro';
      case PetType.cat:
        return 'Gato';
      case PetType.rabbit:
        return 'Conejo';
      case PetType.rodent:
        return 'Roedor';
      case PetType.ferret:
        return 'Hurón';
      case PetType.bird:
        return 'Ave';
      case PetType.fish:
        return 'Pez';
      case PetType.reptile:
        return 'Reptil';
      case PetType.amphibian:
        return 'Anfibio';
      case PetType.invertebrate:
        return 'Invertebrado';
      case PetType.farmAnimal:
        return 'Animal de corral';
      case PetType.other:
        return 'Otro';
    }
  }

  String _getGenderDisplayName(PetGender gender) {
    switch (gender) {
      case PetGender.male:
        return 'Macho';
      case PetGender.female:
        return 'Hembra';
      case PetGender.unknown:
        return 'Desconocido';
    }
  }
}
