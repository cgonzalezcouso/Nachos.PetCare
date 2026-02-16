import 'package:flutter/material.dart';
import 'package:nachos_pet_care_flutter/models/professional.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfessionalsDirectoryScreen extends StatefulWidget {
  const ProfessionalsDirectoryScreen({super.key});

  @override
  State<ProfessionalsDirectoryScreen> createState() =>
      _ProfessionalsDirectoryScreenState();
}

class _ProfessionalsDirectoryScreenState
    extends State<ProfessionalsDirectoryScreen> {
  final List<Professional> _professionals = [];
  bool _isLoading = true;
  ProfessionalType? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  Future<void> _loadProfessionals() async {
    // TODO: Cargar desde la base de datos
    setState(() {
      _professionals.addAll(_getDemoData());
      _isLoading = false;
    });
  }

  List<Professional> _getDemoData() {
    return [
      Professional(
        id: '1',
        name: 'Carlos Martínez',
        type: ProfessionalType.veterinarian,
        businessName: 'Clínica Veterinaria Animales Felices',
        description:
            'Veterinario con 15 años de experiencia en medicina general y cirugía.',
        address: 'Calle Mayor 123, Madrid',
        city: 'Madrid',
        phone: '+34 600 111 222',
        email: 'info@animalesfelices.com',
        website: 'www.animalesfelices.com',
        rating: 4.8,
        specialties: ['Medicina general', 'Cirugía', 'Vacunación'],
        isVerified: true,
      ),
      Professional(
        id: '2',
        name: 'Laura García',
        type: ProfessionalType.trainer,
        description:
            'Adiestradora canina certificada, especializada en educación en positivo.',
        address: 'Avenida Libertad 45, Barcelona',
        city: 'Barcelona',
        phone: '+34 600 333 444',
        email: 'laura@adiestramiento.com',
        rating: 4.9,
        specialties: ['Educación básica', 'Modificación de conducta', 'Agility'],
        isVerified: true,
      ),
      Professional(
        id: '3',
        name: 'Ana López',
        type: ProfessionalType.nutritionist,
        description:
            'Nutricionista especializada en dietas para mascotas con necesidades especiales.',
        address: 'Plaza del Sol 7, Valencia',
        city: 'Valencia',
        phone: '+34 600 555 666',
        email: 'nutricion@mascotassanas.com',
        rating: 4.7,
        specialties: ['Dietas terapéuticas', 'Control de peso', 'Alergias alimentarias'],
        isVerified: false,
      ),
    ];
  }

  List<Professional> get _filteredProfessionals {
    if (_selectedType == null) return _professionals;
    return _professionals.where((p) => p.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Profesionales'),
        actions: [
          PopupMenuButton<ProfessionalType?>(
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
              ...ProfessionalType.values.map((type) {
                return PopupMenuItem(
                  value: type,
                  child: Text(_getTypeDisplayName(type)),
                );
              }),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredProfessionals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay profesionales disponibles',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredProfessionals.length,
                  itemBuilder: (context, index) {
                    final professional = _filteredProfessionals[index];
                    return _ProfessionalCard(professional: professional);
                  },
                ),
    );
  }

  String _getTypeDisplayName(ProfessionalType type) {
    switch (type) {
      case ProfessionalType.trainer:
        return 'Adiestradores';
      case ProfessionalType.nutritionist:
        return 'Nutricionistas';
      case ProfessionalType.ethologist:
        return 'Etólogos';
      case ProfessionalType.groomer:
        return 'Peluqueros';
      case ProfessionalType.veterinarian:
        return 'Veterinarios';
      case ProfessionalType.petFriendly:
        return 'Pet Friendly';
    }
  }
}

class _ProfessionalCard extends StatelessWidget {
  final Professional professional;

  const _ProfessionalCard({required this.professional});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: professional.photoUrl != null &&
                          professional.photoUrl!.isNotEmpty
                      ? NetworkImage(professional.photoUrl!)
                      : null,
                  child: professional.photoUrl == null ||
                          professional.photoUrl!.isEmpty
                      ? Icon(
                          _getIcon(professional.type),
                          size: 30,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              professional.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (professional.isVerified)
                            Icon(
                              Icons.verified,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                      Text(
                        professional.typeDisplayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      if (professional.businessName != null)
                        Text(
                          professional.businessName!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating
            if (professional.rating != null)
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    professional.rating!.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            const SizedBox(height: 8),

            // Descripción
            Text(
              professional.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),

            // Especialidades
            if (professional.specialties.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: professional.specialties.map((specialty) {
                  return Chip(
                    label: Text(
                      specialty,
                      style: const TextStyle(fontSize: 12),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),

            // Ubicación
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
                    '${professional.address}${professional.city != null ? ', ${professional.city}' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Botones de contacto
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makePhoneCall(professional.phone),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Llamar'),
                  ),
                ),
                const SizedBox(width: 8),
                if (professional.email != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _sendEmail(professional.email!),
                      icon: const Icon(Icons.email, size: 18),
                      label: const Text('Email'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(ProfessionalType type) {
    switch (type) {
      case ProfessionalType.trainer:
        return Icons.sports;
      case ProfessionalType.nutritionist:
        return Icons.restaurant;
      case ProfessionalType.ethologist:
        return Icons.psychology;
      case ProfessionalType.groomer:
        return Icons.content_cut;
      case ProfessionalType.veterinarian:
        return Icons.medical_services;
      case ProfessionalType.petFriendly:
        return Icons.storefront;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}
