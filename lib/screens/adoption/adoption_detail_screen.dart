import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nachos_pet_care_flutter/models/adoption_pet.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/providers/adoption_provider.dart';

class AdoptionDetailScreen extends StatefulWidget {
  final String petId;
  const AdoptionDetailScreen({super.key, required this.petId});

  @override
  State<AdoptionDetailScreen> createState() => _AdoptionDetailScreenState();
}

class _AdoptionDetailScreenState extends State<AdoptionDetailScreen> {
  AdoptionPet? _pet;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  Future<void> _loadPet() async {
    // Primero intentar obtenerlo del provider (ya cargado en la lista)
    final provider = context.read<AdoptionProvider>();
    final cached = provider.pets.where((p) => p.id == widget.petId).firstOrNull;
    if (cached != null) {
      setState(() {
        _pet = cached;
        _loading = false;
      });
      return;
    }
    // Si no está en caché, cargarlo del servicio
    try {
      final pet = await provider.service.getAdoptionPetById(widget.petId);
      setState(() {
        _pet = pet;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error ?? 'Animal no encontrado'),
            ],
          ),
        ),
      );
    }

    return _AdoptionDetailBody(pet: _pet!);
  }
}

// ─── Cuerpo principal ─────────────────────────────────────────────────────────

class _AdoptionDetailBody extends StatelessWidget {
  final AdoptionPet pet;
  const _AdoptionDetailBody({required this.pet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── AppBar con imagen hero ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: GestureDetector(
                onTap: () => _openFullScreen(context, pet.photoUrl),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _HeroImage(photoUrl: pet.photoUrl),
                    // Gradiente para legibilidad (no interactivo)
                    const IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                            stops: [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Badge URGENTE (no interactivo)
                    if (pet.isUrgent)
                      Positioned(
                        top: 80,
                        right: 16,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.priority_high,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'URGENTE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenido ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y tipo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_typeDisplay(pet.type)}'
                              '${pet.breed != null ? ' · ${pet.breed}' : ''}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Estado
                      _StatusBadge(status: pet.status),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Chips de características
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.cake_outlined,
                        label: pet.ageDisplay,
                      ),
                      _InfoChip(
                        icon: pet.gender == PetGender.male
                            ? Icons.male
                            : pet.gender == PetGender.female
                                ? Icons.female
                                : Icons.help_outline,
                        label: _genderDisplay(pet.gender),
                      ),
                      _InfoChip(
                        icon: Icons.straighten,
                        label: pet.sizeDisplay,
                      ),
                      if (pet.vaccinated)
                        _InfoChip(
                          icon: Icons.vaccines,
                          label: 'Vacunado',
                          color: Colors.green,
                        ),
                      if (pet.sterilized)
                        _InfoChip(
                          icon: Icons.medical_services_outlined,
                          label: 'Esterilizado',
                          color: Colors.indigo,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _Divider(label: 'Descripción'),
                  const SizedBox(height: 12),

                  Text(
                    pet.description.isNotEmpty
                        ? pet.description
                        : 'Sin descripción disponible.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),

                  const SizedBox(height: 24),
                  _Divider(label: 'Ubicación y refugio'),
                  const SizedBox(height: 12),

                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Localización',
                    value: pet.location.isNotEmpty ? pet.location : '—',
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.home_outlined,
                    label: 'Refugio',
                    value: pet.shelterName.isNotEmpty ? pet.shelterName : '—',
                    color: colorScheme.secondary,
                  ),

                  const SizedBox(height: 24),
                  _Divider(label: 'Contacto'),
                  const SizedBox(height: 16),

                  // Botón teléfono
                  if (pet.contactPhone.isNotEmpty)
                    _ContactButton(
                      icon: Icons.phone_outlined,
                      label: 'Llamar',
                      value: pet.contactPhone,
                      color: Colors.green,
                      onTap: () => _launch('tel:${pet.contactPhone}'),
                    ),

                  if (pet.contactPhone.isNotEmpty &&
                      pet.contactEmail.isNotEmpty)
                    const SizedBox(height: 10),

                  // Botón email
                  if (pet.contactEmail.isNotEmpty)
                    _ContactButton(
                      icon: Icons.email_outlined,
                      label: 'Enviar email',
                      value: pet.contactEmail,
                      color: colorScheme.primary,
                      onTap: () => _launch('mailto:${pet.contactEmail}'),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _openFullScreen(BuildContext context, String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) =>
            _FullScreenNetworkImageViewer(photoUrl: photoUrl),
      ),
    );
  }

  String _typeDisplay(PetType type) {
    const map = {
      PetType.dog: 'Perro',
      PetType.cat: 'Gato',
      PetType.rabbit: 'Conejo',
      PetType.rodent: 'Roedor',
      PetType.ferret: 'Hurón',
      PetType.bird: 'Ave',
      PetType.fish: 'Pez',
      PetType.reptile: 'Reptil',
      PetType.amphibian: 'Anfibio',
      PetType.invertebrate: 'Invertebrado',
      PetType.farmAnimal: 'Animal de corral',
      PetType.other: 'Otro',
    };
    return map[type] ?? 'Animal';
  }

  String _genderDisplay(PetGender g) {
    switch (g) {
      case PetGender.male:
        return 'Macho';
      case PetGender.female:
        return 'Hembra';
      case PetGender.unknown:
        return 'Desconocido';
    }
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final String? photoUrl;
  const _HeroImage({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        },
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.pets,
          size: 100,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

// ─── Visor de imagen a pantalla completa (red) ───────────────────────────────

class _FullScreenNetworkImageViewer extends StatelessWidget {
  final String photoUrl;
  const _FullScreenNetworkImageViewer({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                photoUrl,
                fit: BoxFit.contain,
                headers: const {
                  'User-Agent':
                      'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
                      '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 80,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: SafeArea(
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'available' => ('Disponible', Colors.green),
      'reserved' => ('Reservado', Colors.orange),
      'adopted' => ('Adoptado', Colors.grey),
      _ => ('Disponible', Colors.green),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                fontSize: 12, color: c, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final String label;
  const _Divider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.grey),
              ),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
