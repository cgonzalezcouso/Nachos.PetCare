import 'package:flutter/material.dart';
import 'package:nachos_pet_care_flutter/models/professional.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Pantalla principal ───────────────────────────────────────────────────────

class ProfessionalsDirectoryScreen extends StatefulWidget {
  const ProfessionalsDirectoryScreen({super.key});

  @override
  State<ProfessionalsDirectoryScreen> createState() =>
      _ProfessionalsDirectoryScreenState();
}

class _ProfessionalsDirectoryScreenState
    extends State<ProfessionalsDirectoryScreen> {
  ProfessionalType? _selectedType;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<Professional> get _filtered {
    var list = _allProfessionals();
    if (_selectedType != null) {
      list = list.where((p) => p.type == _selectedType).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              (p.businessName?.toLowerCase().contains(q) ?? false) ||
              (p.city?.toLowerCase().contains(q) ?? false) ||
              p.address.toLowerCase().contains(q) ||
              p.specialties.any((s) => s.toLowerCase().contains(q)))
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Directorio'),
        centerTitle: false,
        actions: [
          PopupMenuButton<ProfessionalType?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar',
            onSelected: (type) => setState(() => _selectedType = type),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Todos')),
              ...ProfessionalType.values.map((t) => PopupMenuItem(
                    value: t,
                    child: Row(children: [
                      Icon(_typeIcon(t), size: 18),
                      const SizedBox(width: 8),
                      Text(_typeName(t)),
                    ]),
                  )),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Buscador ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, ciudad, especialidad…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // ── Chips de categoría ────────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _CategoryChip(
                  label: 'Todos',
                  icon: Icons.apps,
                  selected: _selectedType == null,
                  onTap: () => setState(() => _selectedType = null),
                ),
                ...ProfessionalType.values.map((t) => _CategoryChip(
                      label: _typeName(t),
                      icon: _typeIcon(t),
                      selected: _selectedType == t,
                      onTap: () => setState(() => _selectedType = t),
                    )),
              ],
            ),
          ),

          // ── Contador ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(children: [
              Text(
                '${filtered.length} resultado${filtered.length != 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ]),
          ),

          // ── Lista ─────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('No hay resultados',
                            style: theme.textTheme.titleLarge),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _ProfessionalCard(professional: filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Chip de categoría ────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14,
              color: selected ? colorScheme.onPrimary : colorScheme.primary),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color:
                      selected ? colorScheme.onPrimary : colorScheme.onSurface,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal)),
        ]),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: colorScheme.primary,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ─── Tarjeta ─────────────────────────────────────────────────────────────────

class _ProfessionalCard extends StatelessWidget {
  final Professional professional;
  const _ProfessionalCard({required this.professional});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _typeColor(professional.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera ─────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_typeIcon(professional.type),
                      color: color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              professional.businessName ?? professional.name,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (professional.isVerified)
                            Icon(Icons.verified,
                                size: 16, color: colorScheme.primary),
                        ],
                      ),
                      if (professional.businessName != null)
                        Text(professional.name,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _typeName(professional.type),
                          style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                if (professional.rating != null) ...[
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(
                        professional.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),

            // ── Descripción ───────────────────────────────────────────────
            Text(professional.description,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4)),

            // ── Especialidades ────────────────────────────────────────────
            if (professional.specialties.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: professional.specialties
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer
                                .withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(s,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 10),

            // ── Dirección (tappable → Google Maps) ───────────────────────
            GestureDetector(
              onTap: () => _openMaps(professional.address, professional.city),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 15, color: colorScheme.error),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${professional.address}, ${professional.city ?? ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        decoration: TextDecoration.underline,
                        decorationColor: colorScheme.error,
                      ),
                    ),
                  ),
                  Icon(Icons.open_in_new,
                      size: 12, color: colorScheme.error),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Botones ───────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _call(professional.phone),
                    icon: const Icon(Icons.phone_outlined, size: 16),
                    label: const Text('Llamar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                if (professional.email != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _email(professional.email!),
                      icon: const Icon(Icons.email_outlined, size: 16),
                      label: const Text('Email'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
                if (professional.website != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _web(professional.website!),
                    icon: const Icon(Icons.language, size: 16),
                    label: const Text('Web'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMaps(String address, String? city) async {
    final query = Uri.encodeComponent('$address, ${city ?? 'España'}');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Google Maps no disponible, intentar con geo:
      final geoUri = Uri.parse('geo:0,0?q=$query');
      try { await launchUrl(geoUri, mode: LaunchMode.externalApplication); } catch (_) {}
    }
  }

  Future<void> _call(String phone) async {
    final cleaned = phone.replaceAll(' ', '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  Future<void> _email(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  Future<void> _web(String website) async {
    final url = website.startsWith('http') ? website : 'https://$website';
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}

// ─── Helpers de tipo ──────────────────────────────────────────────────────────

String _typeName(ProfessionalType t) {
  switch (t) {
    case ProfessionalType.trainer:      return 'Adiestrador';
    case ProfessionalType.nutritionist: return 'Nutricionista';
    case ProfessionalType.ethologist:   return 'Etólogo';
    case ProfessionalType.groomer:      return 'Peluquero';
    case ProfessionalType.veterinarian: return 'Veterinario';
    case ProfessionalType.petFriendly:  return 'Pet Friendly';
  }
}

IconData _typeIcon(ProfessionalType t) {
  switch (t) {
    case ProfessionalType.trainer:      return Icons.sports;
    case ProfessionalType.nutritionist: return Icons.restaurant_outlined;
    case ProfessionalType.ethologist:   return Icons.psychology_outlined;
    case ProfessionalType.groomer:      return Icons.content_cut;
    case ProfessionalType.veterinarian: return Icons.medical_services_outlined;
    case ProfessionalType.petFriendly:  return Icons.storefront_outlined;
  }
}

Color _typeColor(ProfessionalType t) {
  switch (t) {
    case ProfessionalType.trainer:      return Colors.orange;
    case ProfessionalType.nutritionist: return Colors.green;
    case ProfessionalType.ethologist:   return Colors.purple;
    case ProfessionalType.groomer:      return Colors.pink;
    case ProfessionalType.veterinarian: return Colors.blue;
    case ProfessionalType.petFriendly:  return Colors.teal;
  }
}

// ─── Datos reales ─────────────────────────────────────────────────────────────

List<Professional> _allProfessionals() => [

  // ══ VETERINARIOS ══════════════════════════════════════════════════════════

  Professional(
    id: 'v01',
    name: 'Hospital Veterinario Universidad Complutense',
    type: ProfessionalType.veterinarian,
    businessName: 'Hospital Clínico Veterinario UCM',
    description: 'Hospital universitario de referencia nacional. Atención de urgencias 24h, especialistas en todas las áreas y equipamiento de última generación.',
    address: 'Avda. Puerta de Hierro s/n',
    city: 'Madrid',
    phone: '+34 913 943 682',
    email: 'hcv@ucm.es',
    website: 'www.ucm.es/hcv',
    rating: 4.7,
    specialties: ['Urgencias 24h', 'Oncología', 'Cardiología', 'Neurología', 'Exóticos'],
    isVerified: true,
  ),
  Professional(
    id: 'v02',
    name: 'Clínica Veterinaria Tecnos',
    type: ProfessionalType.veterinarian,
    businessName: 'Clínica Veterinaria Tecnos',
    description: 'Clínica veterinaria de referencia en Barcelona con más de 20 años, equipada con escáner TC y resonancia magnética.',
    address: 'Carrer de Londres, 51',
    city: 'Barcelona',
    phone: '+34 932 184 720',
    email: 'info@clinicatecnos.com',
    website: 'www.clinicatecnos.com',
    rating: 4.8,
    specialties: ['Diagnóstico por imagen', 'Oftalmología', 'Dermatología', 'Cirugía'],
    isVerified: true,
  ),
  Professional(
    id: 'v03',
    name: 'Hospital Veterinario San Vicente',
    type: ProfessionalType.veterinarian,
    businessName: 'Hospital Veterinario San Vicente',
    description: 'Hospital de 24h con UCI, banco de sangre y más de 30 veterinarios especialistas. Referencia en el sur de España.',
    address: 'Avda. San Vicente Mártir, 184',
    city: 'Valencia',
    phone: '+34 963 486 611',
    email: 'info@hospitalsanvicente.com',
    website: 'www.hospitalsanvicente.com',
    rating: 4.9,
    specialties: ['UCI animal', 'Banco de sangre', 'Rehabilitación', 'Reproducción'],
    isVerified: true,
  ),
  Professional(
    id: 'v04',
    name: 'Clínica Veterinaria Dieciséis',
    type: ProfessionalType.veterinarian,
    businessName: 'Clínica Veterinaria Dieciséis',
    description: 'Clínica de referencia en Sevilla con servicio de urgencias, hospitalización y especialistas en fauna silvestre.',
    address: 'Calle Luis de Morales, 16',
    city: 'Sevilla',
    phone: '+34 954 577 900',
    email: 'info@clinica16.com',
    website: 'www.clinica16.com',
    rating: 4.6,
    specialties: ['Medicina interna', 'Fauna silvestre', 'Hospitalización', 'Urgencias'],
    isVerified: true,
  ),
  Professional(
    id: 'v05',
    name: 'AniCura Hospital Veterinario Bienestar',
    type: ProfessionalType.veterinarian,
    businessName: 'AniCura Bienestar',
    description: 'Parte de la red europea AniCura. Atención especializada en perros y gatos con los más altos estándares de calidad europeos.',
    address: 'Calle Padilla, 22',
    city: 'Madrid',
    phone: '+34 914 016 801',
    email: 'bienestar@anicura.es',
    website: 'www.anicura.es',
    rating: 4.7,
    specialties: ['Oncología', 'Cardiología', 'Endoscopia', 'Ecografías'],
    isVerified: true,
  ),
  Professional(
    id: 'v06',
    name: 'Hospital Veterinario Canis',
    type: ProfessionalType.veterinarian,
    businessName: 'Hospital Veterinario Canis',
    description: 'Hospital de referencia en Zaragoza. Urgencias 24h, UCI, medicina interna y unidad de reproducción asistida.',
    address: 'Calle García Sánchez, 15',
    city: 'Zaragoza',
    phone: '+34 976 220 640',
    email: 'info@hospitalcanivet.com',
    website: 'www.hospitalcanivet.com',
    rating: 4.5,
    specialties: ['Reproducción asistida', 'Traumatología', 'Urgencias 24h'],
    isVerified: true,
  ),

  // ══ ADIESTRADORES ═════════════════════════════════════════════════════════

  Professional(
    id: 'a01',
    name: 'Marcos Gómez',
    type: ProfessionalType.trainer,
    businessName: 'Escuela Canina Educación en Positivo',
    description: 'Adiestrador titulado por la APDT (Association of Professional Dog Trainers). Especialista en modificación de conducta y rehabilitación de perros agresivos.',
    address: 'Calle Alcalá, 320',
    city: 'Madrid',
    phone: '+34 628 441 271',
    email: 'marcos@educacionenpositivo.es',
    website: 'www.educacionenpositivo.es',
    rating: 4.9,
    specialties: ['Educación en positivo', 'Agresividad', 'Ansiedad por separación', 'Cachorros'],
    isVerified: true,
  ),
  Professional(
    id: 'a02',
    name: 'Sara Pérez',
    type: ProfessionalType.trainer,
    businessName: 'K9 Training Barcelona',
    description: 'Adiestradora certificada IABCh. Especialista en trabajo con razas de trabajo (malinois, border collie, husky). Clases individuales y grupales.',
    address: 'Carrer de la Marina, 95',
    city: 'Barcelona',
    phone: '+34 611 384 920',
    email: 'info@k9barcelona.com',
    website: 'www.k9barcelona.com',
    rating: 4.8,
    specialties: ['Razas de trabajo', 'Agility', 'Obediencia avanzada', 'Deporte canino'],
    isVerified: true,
  ),
  Professional(
    id: 'a03',
    name: 'Francisco Navarro',
    type: ProfessionalType.trainer,
    businessName: 'Centro Canino El Señorío',
    description: 'Centro de adiestramiento y residencia canina con más de 25 años de experiencia. Cachorro, obediencia básica y avanzada.',
    address: 'Ctra. de la Pechina km 2',
    city: 'Almería',
    phone: '+34 950 143 288',
    email: 'francisconavarro@elsenorio.com',
    website: 'www.elsenorio.com',
    rating: 4.6,
    specialties: ['Adiestramiento básico', 'Pensión canina', 'Cachorros', 'RAE'],
    isVerified: false,
  ),
  Professional(
    id: 'a04',
    name: 'Lucía Blanco',
    type: ProfessionalType.trainer,
    businessName: 'Perros en Positivo Valencia',
    description: 'Adiestradora con enfoque 100% libre de castigo. Socióloga animal. Especialista en perros rescatados y con historial de maltrato.',
    address: 'Avda. del Puerto, 122',
    city: 'Valencia',
    phone: '+34 699 211 840',
    email: 'lucia@perrosenpositivo.com',
    website: 'www.perrosenpositivo.com',
    rating: 5.0,
    specialties: ['Perros rescatados', 'Miedo y fobias', 'Clicker training', 'Cachorros'],
    isVerified: true,
  ),
  Professional(
    id: 'a05',
    name: 'Diego Ruiz',
    type: ProfessionalType.trainer,
    businessName: 'Can Training Bilbao',
    description: 'Adiestrador certificado por AEDAC. Atención a domicilio en toda la provincia de Vizcaya. Especialista en educación urbana.',
    address: 'Gran Vía de Don Diego López de Haro, 42',
    city: 'Bilbao',
    phone: '+34 635 892 114',
    email: 'info@cantrainingbilbao.com',
    website: 'www.cantrainingbilbao.com',
    rating: 4.7,
    specialties: ['Educación urbana', 'Paseos en positivo', 'A domicilio', 'Reactivos'],
    isVerified: true,
  ),

  // ══ ETÓLOGOS ══════════════════════════════════════════════════════════════

  Professional(
    id: 'e01',
    name: 'Dra. Paloma Esteve',
    type: ProfessionalType.ethologist,
    businessName: 'Etología Clínica Veterinaria Esteve',
    description: 'Veterinaria especialista en etología clínica (Diplomada ECAWBM). Diagnóstico y tratamiento de trastornos del comportamiento con o sin apoyo farmacológico.',
    address: 'Calle Goya, 87',
    city: 'Madrid',
    phone: '+34 914 358 740',
    email: 'consulta@etologiaesteve.com',
    website: 'www.etologiaesteve.com',
    rating: 4.9,
    specialties: ['Ansiedad', 'Agresividad', 'Miedos', 'Terapia farmacológica', 'Gatos'],
    isVerified: true,
  ),
  Professional(
    id: 'e02',
    name: 'Dr. Javier Moral',
    type: ProfessionalType.ethologist,
    businessName: 'Conductavet Barcelona',
    description: 'Veterinario etólogo con doctorado en ciencias del comportamiento animal por la UAB. Especialista en medicina del comportamiento felino.',
    address: 'Avda. Diagonal, 407',
    city: 'Barcelona',
    phone: '+34 932 413 615',
    email: 'javier@conductavet.com',
    website: 'www.conductavet.com',
    rating: 4.8,
    specialties: ['Comportamiento felino', 'Multiespecie', 'Enriquecimiento ambiental'],
    isVerified: true,
  ),
  Professional(
    id: 'e03',
    name: 'Carmen García',
    type: ProfessionalType.ethologist,
    businessName: 'Ethos Animal',
    description: 'Etóloga y bióloga especializada en fauna doméstica y exótica. Consultas presenciales y online. Diagnóstico conductual sin medicación en la mayoría de casos.',
    address: 'Calle Menéndez Pelayo, 23',
    city: 'Sevilla',
    phone: '+34 618 229 003',
    email: 'carmen@ethosanimal.es',
    website: 'www.ethosanimal.es',
    rating: 4.9,
    specialties: ['Fauna exótica', 'Consulta online', 'Conejos', 'Aves psitácidas'],
    isVerified: true,
  ),

  // ══ NUTRICIONISTAS ════════════════════════════════════════════════════════

  Professional(
    id: 'n01',
    name: 'Dra. Elena Martínez',
    type: ProfessionalType.nutritionist,
    businessName: 'NutriVet Canino',
    description: 'Veterinaria especialista en nutrición clínica animal. Formulación de dietas caseras cocinadas y crudas (BARF) adaptadas a cada paciente.',
    address: 'Calle Serrano, 48',
    city: 'Madrid',
    phone: '+34 913 102 281',
    email: 'elena@nutrivetcanino.com',
    website: 'www.nutrivetcanino.com',
    rating: 4.8,
    specialties: ['Dieta BARF', 'Dieta cocinada', 'Obesidad', 'Insuficiencia renal', 'Alergias'],
    isVerified: true,
  ),
  Professional(
    id: 'n02',
    name: 'Dra. Laura Font',
    type: ProfessionalType.nutritionist,
    businessName: 'Nutrición Animal Font',
    description: 'Especialista en nutrición de gatos y perros senior. Colaboradora del Consejo Superior de Investigaciones Científicas (CSIC) en proyectos de alimentación animal.',
    address: 'Carrer del Consell de Cent, 315',
    city: 'Barcelona',
    phone: '+34 932 155 780',
    email: 'laurafont@nutricionfont.com',
    website: 'www.nutricionfont.com',
    rating: 4.9,
    specialties: ['Senior', 'Enfermedades crónicas', 'Pienso de alta gama', 'Consulta online'],
    isVerified: true,
  ),
  Professional(
    id: 'n03',
    name: 'Miguel Torres',
    type: ProfessionalType.nutritionist,
    businessName: 'BARFVida',
    description: 'Técnico en nutrición animal especializado en dieta cruda (BARF). Formación, talleres y planes nutricionales personalizados para perros y gatos.',
    address: 'Calle Toro, 28',
    city: 'Salamanca',
    phone: '+34 680 112 344',
    email: 'info@barfvida.es',
    website: 'www.barfvida.es',
    rating: 4.7,
    specialties: ['BARF', 'Menú barfero', 'Talleres', 'Cachorros', 'Gestantes'],
    isVerified: false,
  ),

  // ══ PELUQUEROS ════════════════════════════════════════════════════════════

  Professional(
    id: 'p01',
    name: 'Nuria Castro',
    type: ProfessionalType.groomer,
    businessName: 'Glamour Canino Madrid',
    description: 'Peluquera canina certificada IGROOMER con 12 años de experiencia. Especialista en cortes de raza y spa para mascotas.',
    address: 'Calle Alcobendas, 5',
    city: 'Madrid',
    phone: '+34 912 774 190',
    email: 'nuria@glamourcanino.es',
    website: 'www.glamourcanino.es',
    rating: 4.8,
    specialties: ['Cortes de raza', 'Spa canino', 'Baño medicado', 'Tratamiento de pelo'],
    isVerified: true,
  ),
  Professional(
    id: 'p02',
    name: 'Tomás Gil',
    type: ProfessionalType.groomer,
    businessName: 'Pets & Style Barcelona',
    description: 'Peluquero profesional ganador de varios campeonatos de España. Especialista en razas nórdicas, perros de agua y cockers.',
    address: 'Carrer de Sants, 182',
    city: 'Barcelona',
    phone: '+34 933 321 011',
    email: 'info@petsstyle.com',
    website: 'www.petsstyle.com',
    rating: 4.9,
    specialties: ['Razas nórdicas', 'Cockers', 'Competición', 'Galgo', 'Podología canina'],
    isVerified: true,
  ),
  Professional(
    id: 'p03',
    name: 'Isabel Ramos',
    type: ProfessionalType.groomer,
    businessName: 'La Peluquería de Rex',
    description: 'Peluquería canina y felina con servicio de recogida a domicilio. Especialistas en gatos y razas pequeñas. Atención personalizada y sin jaulas.',
    address: 'Calle San Francisco, 34',
    city: 'Valencia',
    phone: '+34 963 718 240',
    email: 'hola@lapeluqueriaderex.com',
    website: 'www.lapeluqueriaderex.com',
    rating: 4.7,
    specialties: ['Sin jaulas', 'Gatos', 'Recogida a domicilio', 'Terapia con ozono'],
    isVerified: true,
  ),
  Professional(
    id: 'p04',
    name: 'Andrea Vega',
    type: ProfessionalType.groomer,
    businessName: 'Mirlo Peluquería Animal',
    description: 'Centro de bienestar y estética para mascotas en Bilbao. Productos ecológicos y libres de parabenos. Atención individualizada sin estrés.',
    address: 'Calle Particular de Estraunza, 3',
    city: 'Bilbao',
    phone: '+34 944 431 881',
    email: 'andrea@mirlopeluqueria.com',
    website: 'www.mirlopeluqueria.com',
    rating: 4.8,
    specialties: ['Productos ecológicos', 'Aromaterapia', 'Masajes', 'Sin químicos agresivos'],
    isVerified: true,
  ),
  Professional(
    id: 'p05',
    name: 'Rosa Fernández',
    type: ProfessionalType.groomer,
    businessName: 'Gatitos & Perritos Grooming',
    description: 'Peluquería especializada en gatos con sala separada insonorizada. Único centro certificado Kata Fácil (manejo felino sin estrés) en Málaga.',
    address: 'Calle Mármoles, 15',
    city: 'Málaga',
    phone: '+34 951 220 441',
    email: 'rosa@gatitosperritos.com',
    website: 'www.gatitosperritos.com',
    rating: 4.9,
    specialties: ['Especialista felino', 'Kata Fácil', 'Sala exclusiva gatos', 'Pelaje largo'],
    isVerified: true,
  ),

  // ══ PET FRIENDLY – Bares y Cafeterías ════════════════════════════════════

  Professional(
    id: 'pf01',
    name: 'Café de los Perros',
    type: ProfessionalType.petFriendly,
    businessName: 'Café de los Perros',
    description: 'El primer dog café de Madrid. Terraza completamente habilitada para perros, con dispensadores de agua, snacks para mascotas y personal que adora a los animales.',
    address: 'Calle Ponzano, 14',
    city: 'Madrid',
    phone: '+34 910 424 141',
    email: 'hola@cafedelosperros.es',
    website: 'www.cafedelosperros.es',
    rating: 4.7,
    specialties: ['Terraza dog-friendly', 'Snacks para mascotas', 'Agua gratis', 'Eventos'],
    isVerified: true,
  ),
  Professional(
    id: 'pf02',
    name: 'The Dogfather',
    type: ProfessionalType.petFriendly,
    businessName: 'The Dogfather Gastrobar',
    description: 'Gastrobar pet-friendly en el Eixample barcelonés. Carta de hamburguesas gourmet. Los perros tienen su propio menú y zona de descanso.',
    address: 'Carrer del Consell de Cent, 255',
    city: 'Barcelona',
    phone: '+34 934 513 720',
    email: 'reservas@thedogfather.es',
    website: 'www.thedogfather.es',
    rating: 4.6,
    specialties: ['Menú para perros', 'Zona descanso', 'Terraza', 'Todos los tamaños'],
    isVerified: true,
  ),
  Professional(
    id: 'pf03',
    name: 'La Perrería Gastrobar',
    type: ProfessionalType.petFriendly,
    businessName: 'La Perrería',
    description: 'Gastrobar en Valencia donde los perros son bienvenidos dentro y fuera. Bebedero integrado en la barra y zona de snacks al 50% del precio.',
    address: 'Calle Ruzafa, 7',
    city: 'Valencia',
    phone: '+34 963 512 008',
    email: 'info@laperreriavalencia.com',
    website: 'www.laperreriavalencia.com',
    rating: 4.7,
    specialties: ['Interior dog-friendly', 'Descuento snacks', 'Terraza amplia'],
    isVerified: true,
  ),
  Professional(
    id: 'pf04',
    name: 'Muerde la Pasta',
    type: ProfessionalType.petFriendly,
    businessName: 'Muerde la Pasta – Varias ciudades',
    description: 'Cadena de restaurantes italianos pet-friendly con locales en más de 15 ciudades españolas. Terraza siempre disponible para perros, agua y snacks de bienvenida.',
    address: 'Gran Vía, 55',
    city: 'Madrid',
    phone: '+34 910 010 500',
    email: 'info@muerderapasta.es',
    website: 'www.muerdelapasta.es',
    rating: 4.4,
    specialties: ['Cadena nacional', 'Terrazas amplias', 'Snacks bienvenida', 'Reservas online'],
    isVerified: true,
  ),

  // ══ PET FRIENDLY – Tiendas ════════════════════════════════════════════════

  Professional(
    id: 'pf05',
    name: 'El Corte Inglés – Sección Mascotas',
    type: ProfessionalType.petFriendly,
    businessName: 'El Corte Inglés Pet Corner',
    description: 'Muchos centros de El Corte Inglés permiten la entrada de perros con correa en toda la planta de mascotas y zonas de alimentación animal. Consulta con cada centro.',
    address: 'Calle Preciados, 3',
    city: 'Madrid',
    phone: '+34 913 795 800',
    email: 'atencioncliente@elcorteingles.es',
    website: 'www.elcorteingles.es',
    rating: 4.2,
    specialties: ['Tienda de animales', 'Peluquería en centro', 'Amplio surtido', 'Click & Collect'],
    isVerified: true,
  ),
  Professional(
    id: 'pf06',
    name: 'Leroy Merlin',
    type: ProfessionalType.petFriendly,
    businessName: 'Leroy Merlin España',
    description: 'Todos los centros Leroy Merlin de España admiten perros con correa y bien educados en sus instalaciones. Tienden a tener puntos de agua para perros en la entrada.',
    address: 'Ctra. de Fuencarral-Alcobendas km 12',
    city: 'Madrid',
    phone: '+34 900 400 500',
    email: 'atencioncliente@leroymerlin.es',
    website: 'www.leroymerlin.es',
    rating: 4.5,
    specialties: ['Perros con correa admitidos', 'Agua a la entrada', 'Todo el centro'],
    isVerified: true,
  ),
  Professional(
    id: 'pf07',
    name: 'Kiwoko',
    type: ProfessionalType.petFriendly,
    businessName: 'Kiwoko Tiendas de Animales',
    description: 'Cadena de tiendas especializadas en animales. Más de 80 tiendas en España. Admiten mascotas dentro, servicio de adopción y peluquería en muchos centros.',
    address: 'Avda. de Burgos, 109',
    city: 'Madrid',
    phone: '+34 900 808 877',
    email: 'contacto@kiwoko.com',
    website: 'www.kiwoko.com',
    rating: 4.3,
    specialties: ['Tienda pet-friendly', 'Adopciones', 'Peluquería', 'Clínica veterinaria básica'],
    isVerified: true,
  ),
  Professional(
    id: 'pf08',
    name: 'Zara Home',
    type: ProfessionalType.petFriendly,
    businessName: 'Zara Home – Tiendas seleccionadas',
    description: 'Varias tiendas Zara Home en España permiten la entrada de perros pequeños y medianos con correa. Consulta con cada establecimiento antes de ir.',
    address: 'Calle José Ortega y Gasset, 6',
    city: 'Madrid',
    phone: '+34 913 616 300',
    email: 'atencion@zarahome.com',
    website: 'www.zarahome.com',
    rating: 4.1,
    specialties: ['Perros pequeños/medianos', 'Correa obligatoria', 'Preguntar en tienda'],
    isVerified: false,
  ),

  // ══ PET FRIENDLY – Hoteles ════════════════════════════════════════════════

  Professional(
    id: 'pf09',
    name: 'Hotel NH Collection Madrid Suecia',
    type: ProfessionalType.petFriendly,
    businessName: 'NH Collection Madrid Suecia',
    description: 'Hotel de 5 estrellas en el centro de Madrid que admite mascotas de hasta 10 kg. Ofrecen cama, cuencos y snacks de bienvenida para perros y gatos.',
    address: 'Calle del Marqués de Casa Riera, 4',
    city: 'Madrid',
    phone: '+34 914 956 900',
    email: 'nhcollectionmadridsuecia@nh-hotels.com',
    website: 'www.nh-hotels.com',
    rating: 4.7,
    specialties: ['5 estrellas', 'Cama para mascota', 'Cuencos y snacks', 'Centro ciudad'],
    isVerified: true,
  ),
  Professional(
    id: 'pf10',
    name: 'Hotel Arts Barcelona',
    type: ProfessionalType.petFriendly,
    businessName: 'Hotel Arts Barcelona – The Ritz-Carlton',
    description: 'Icónico hotel de lujo frente al mar en Barcelona. Admite mascotas con servicio de bienvenida personalizado, menú especial y paseo con cuidador.',
    address: 'Carrer de la Marina, 19-21',
    city: 'Barcelona',
    phone: '+34 932 211 000',
    email: 'barcelona@ritzcarlton.com',
    website: 'www.hotelartsbarcelona.com',
    rating: 4.8,
    specialties: ['Lujo pet-friendly', 'Servicio de paseo', 'Menú para mascotas', 'Playa cercana'],
    isVerified: true,
  ),
  Professional(
    id: 'pf11',
    name: 'Parador de Granada',
    type: ProfessionalType.petFriendly,
    businessName: 'Parador de Granada',
    description: 'El único Parador de España ubicado dentro de la Alhambra. Admite perros de hasta 15 kg con depósito. Jardines enormes para paseos al amanecer.',
    address: 'Real de la Alhambra s/n',
    city: 'Granada',
    phone: '+34 958 221 440',
    email: 'granada@parador.es',
    website: 'www.parador.es',
    rating: 4.9,
    specialties: ['Interior Alhambra', 'Jardines históricos', 'Hasta 15 kg', 'Ambiente único'],
    isVerified: true,
  ),
  Professional(
    id: 'pf12',
    name: 'Rusticae – Casas rurales pet-friendly',
    type: ProfessionalType.petFriendly,
    businessName: 'Rusticae Hoteles con Encanto',
    description: 'Selección de más de 200 hoteles y casas rurales de toda España que admiten mascotas. Plataforma con filtro pet-friendly y garantía de calidad Rusticae.',
    address: 'Calle Serrano, 23',
    city: 'Madrid',
    phone: '+34 914 313 509',
    email: 'info@rusticae.es',
    website: 'www.rusticae.es',
    rating: 4.6,
    specialties: ['200+ alojamientos', 'Toda España', 'Filtro pet-friendly', 'Garantía calidad'],
    isVerified: true,
  ),

  // ══ PET FRIENDLY – Centros Comerciales ═══════════════════════════════════

  Professional(
    id: 'pf13',
    name: 'Centro Comercial Tres Aguas',
    type: ProfessionalType.petFriendly,
    businessName: 'CC Tres Aguas – Alcorcón',
    description: 'Centro comercial en Alcorcón (Madrid) que permite la entrada de perros con correa en todas sus zonas comunes y establecimientos adheridos.',
    address: 'Avda. Partenón, 16',
    city: 'Alcorcón (Madrid)',
    phone: '+34 916 422 680',
    email: 'info@tresaguas.com',
    website: 'www.tresaguas.es',
    rating: 4.3,
    specialties: ['Perros con correa', 'Zonas comunes', 'Peluquería animal', 'Kiwoko dentro'],
    isVerified: true,
  ),
  Professional(
    id: 'pf14',
    name: 'La Maquinista',
    type: ProfessionalType.petFriendly,
    businessName: 'Centro Comercial La Maquinista – Barcelona',
    description: 'Uno de los centros comerciales más grandes de Barcelona al aire libre. Admite perros en las zonas exteriores y algunos establecimientos interiores.',
    address: 'Carrer de Potosí, 2',
    city: 'Barcelona',
    phone: '+34 933 603 700',
    email: 'lamaquinista@unibail-rodamco.es',
    website: 'www.lamaquinista.com',
    rating: 4.2,
    specialties: ['Zona exterior dog-friendly', 'Parking con área de descanso animal'],
    isVerified: true,
  ),

  // ══ PET FRIENDLY – Playa y Espacios ══════════════════════════════════════

  Professional(
    id: 'pf15',
    name: 'Playa de El Saler',
    type: ProfessionalType.petFriendly,
    businessName: 'Zona Canina Playa El Saler',
    description: 'Playa habilitada para perros en Valencia, dentro del Parque Natural de la Albufera. Zona vallada, acceso libre de noviembre a mayo y zona específica en verano.',
    address: 'Playa de El Saler s/n',
    city: 'Valencia',
    phone: '+34 963 869 100',
    email: 'parques@valencia.es',
    website: 'www.valencia.es/medioambiente',
    rating: 4.5,
    specialties: ['Playa canina', 'Libre en invierno', 'Zona vallada verano', 'Parque Natural'],
    isVerified: true,
  ),
  Professional(
    id: 'pf16',
    name: 'Cine Yelmo – Screens pet-friendly',
    type: ProfessionalType.petFriendly,
    businessName: 'Cines Yelmo Cine con Mascotas',
    description: 'Sesiones especiales dog-friendly en algunos complejos Yelmo. El programa "Cine con Mascotas" permite asistir con perros a proyecciones seleccionadas.',
    address: 'Avda. de la Galaxia s/n',
    city: 'Madrid',
    phone: '+34 902 220 922',
    email: 'atencioncliente@yelmocines.es',
    website: 'www.yelmocines.es',
    rating: 4.0,
    specialties: ['Sesiones dog-friendly', 'Programa especial', 'Consultar cartelera'],
    isVerified: true,
  ),

  // ══ VETERINARIOS (adicionales) ════════════════════════════════════════════

  Professional(
    id: 'v07',
    name: 'Hospital Veterinario Puchol',
    type: ProfessionalType.veterinarian,
    businessName: 'Hospital Veterinario Puchol',
    description: 'Hospital de referencia en Murcia con más de 30 años. Urgencias 24h, UCI, oncología y unidad de reproducción asistida.',
    address: 'Avda. Juan Carlos I, 42',
    city: 'Murcia',
    phone: '+34 968 235 010',
    email: 'info@hospitalpuchol.com',
    website: 'www.hospitalpuchol.com',
    rating: 4.6,
    specialties: ['Urgencias 24h', 'UCI', 'Oncología', 'Reproducción'],
    isVerified: true,
  ),
  Professional(
    id: 'v08',
    name: 'Clínica Veterinaria Vetsalud',
    type: ProfessionalType.veterinarian,
    businessName: 'Vetsalud Bilbao',
    description: 'Clínica de referencia en el País Vasco, especializada en medicina interna, dermatología y rehabilitación animal.',
    address: 'Alameda de Rekalde, 30',
    city: 'Bilbao',
    phone: '+34 944 273 600',
    email: 'info@vetsalud.es',
    website: 'www.vetsalud.es',
    rating: 4.7,
    specialties: ['Dermatología', 'Rehabilitación', 'Medicina interna', 'Fisioterapia'],
    isVerified: true,
  ),
  Professional(
    id: 'v09',
    name: 'Hospital Veterinario Vetsia',
    type: ProfessionalType.veterinarian,
    businessName: 'Hospital Veterinario Vetsia',
    description: 'Hospital 24h en Málaga con tomografía computarizada, resonancia magnética y banco de sangre propio.',
    address: 'Calle Compositor Lehmberg Ruiz, 10',
    city: 'Málaga',
    phone: '+34 951 014 244',
    email: 'info@vetsia.com',
    website: 'www.vetsia.com',
    rating: 4.8,
    specialties: ['TC', 'Resonancia', 'Banco de sangre', 'Urgencias 24h'],
    isVerified: true,
  ),
  Professional(
    id: 'v10',
    name: 'Clínica Veterinaria Complutum',
    type: ProfessionalType.veterinarian,
    businessName: 'Clínica Veterinaria Complutum',
    description: 'Clínica veterinaria en Alcalá de Henares con más de 20 años. Especialistas en fauna exótica y animales silvestres.',
    address: 'Calle Mayor, 38',
    city: 'Alcalá de Henares (Madrid)',
    phone: '+34 918 812 360',
    email: 'info@clinicacomplutum.es',
    website: 'www.clinicacomplutum.es',
    rating: 4.5,
    specialties: ['Exóticos', 'Silvestres', 'Reptiles', 'Aves'],
    isVerified: true,
  ),
  Professional(
    id: 'v11',
    name: 'Hospital Veterinario Duques de Soria',
    type: ProfessionalType.veterinarian,
    businessName: 'HV Duques de Soria',
    description: 'Hospital de referencia del noroeste de España con especialidades en neurología, cardiología y traumatología.',
    address: 'Glorieta de Mariano Granados, 4',
    city: 'Valladolid',
    phone: '+34 983 394 094',
    email: 'info@hvds.es',
    website: 'www.hvds.es',
    rating: 4.6,
    specialties: ['Neurología', 'Cardiología', 'Traumatología', 'Hospitalización'],
    isVerified: true,
  ),
  Professional(
    id: 'v12',
    name: 'Clínica Veterinaria Palao',
    type: ProfessionalType.veterinarian,
    businessName: 'Clínica Veterinaria Palao',
    description: 'Veterinaria de familia con más de 35 años en Zaragoza. Reconocida por su trato cercano y especialización en geriátrica animal.',
    address: 'Paseo Fernando el Católico, 62',
    city: 'Zaragoza',
    phone: '+34 976 561 720',
    email: 'clinica@veterinariapalao.com',
    website: 'www.veterinariapalao.com',
    rating: 4.9,
    specialties: ['Geriátrica', 'Odontología', 'Ecografía', 'Laboratorio'],
    isVerified: true,
  ),
  Professional(
    id: 'v13',
    name: 'Hospital Veterinario Santas Martas',
    type: ProfessionalType.veterinarian,
    businessName: 'Hospital Veterinario Santas Martas',
    description: 'Referencia veterinaria en Santiago de Compostela. Urgencias 24h, cirugía de alta complejidad y oncología.',
    address: 'Rúa das Santas Martas, 2',
    city: 'Santiago de Compostela',
    phone: '+34 981 582 822',
    email: 'info@hvsantasmartas.com',
    website: 'www.hvsantasmartas.com',
    rating: 4.7,
    specialties: ['Urgencias 24h', 'Oncología', 'Cirugía ortopédica'],
    isVerified: true,
  ),
  Professional(
    id: 'v14',
    name: 'Clínica Veterinaria Quart',
    type: ProfessionalType.veterinarian,
    businessName: 'Clínica Veterinaria Quart',
    description: 'Amplia clínica en Valencia con endoscopia, laboratorio propio y espacio de espera separado para perros y gatos.',
    address: 'Avda. del Cid, 105',
    city: 'Valencia',
    phone: '+34 963 790 490',
    email: 'info@clinicaquart.com',
    website: 'www.clinicaquart.com',
    rating: 4.6,
    specialties: ['Endoscopia', 'Lab propio', 'Sala espera separada', 'Odontología'],
    isVerified: true,
  ),
  Professional(
    id: 'v15',
    name: 'Clínica Veterinaria Centro',
    type: ProfessionalType.veterinarian,
    businessName: 'Clínica Veterinaria Centro Sevilla',
    description: 'Veterinaria en el corazón de Sevilla. Atención de pequeños animales, exóticos y aves. Servicio de acupuntura veterinaria.',
    address: 'Calle Feria, 85',
    city: 'Sevilla',
    phone: '+34 954 906 312',
    email: 'contacto@veterinariacentro.es',
    website: 'www.veterinariacentro.es',
    rating: 4.5,
    specialties: ['Exóticos', 'Aves', 'Acupuntura', 'Homeopatía veterinaria'],
    isVerified: false,
  ),

  // ══ ADIESTRADORES (adicionales) ═══════════════════════════════════════════

  Professional(
    id: 'a06',
    name: 'Raquel Sanz',
    type: ProfessionalType.trainer,
    businessName: 'SanzCan Adiestramiento',
    description: 'Adiestradora certificada por ACAE. Especialista en nosework (olfato deportivo) y rally obedience. Campeona de España 2022 en nosework.',
    address: 'Calle San Millán, 17',
    city: 'Logroño',
    phone: '+34 617 334 820',
    email: 'raquel@sanzcan.es',
    website: 'www.sanzcan.es',
    rating: 5.0,
    specialties: ['Nosework', 'Rally obedience', 'Deporte canino', 'Campeona España'],
    isVerified: true,
  ),
  Professional(
    id: 'a07',
    name: 'Alberto Montoya',
    type: ProfessionalType.trainer,
    businessName: 'Perro Feliz Sevilla',
    description: 'Adiestrador y educador canino con más de 15 años. Especialista en perros de trabajo y equipos de búsqueda y rescate (SAR).',
    address: 'Avda. Kansas City, 12',
    city: 'Sevilla',
    phone: '+34 638 771 440',
    email: 'alberto@perrofeliz.es',
    website: 'www.perrofeliz.es',
    rating: 4.8,
    specialties: ['Búsqueda y rescate', 'Perros de trabajo', 'Detección', 'Obediencia'],
    isVerified: true,
  ),
  Professional(
    id: 'a08',
    name: 'Nadia Herrero',
    type: ProfessionalType.trainer,
    businessName: 'The Happy Dog Zaragoza',
    description: 'Adiestradora y consultora de comportamiento canino. Especialista en razas guardianas (Mastiff, Rottweiler, Dobermann) y en socialización temprana.',
    address: 'Calle Compromiso de Caspe, 32',
    city: 'Zaragoza',
    phone: '+34 622 891 003',
    email: 'nadia@thehappydog.es',
    website: 'www.thehappydog.es',
    rating: 4.9,
    specialties: ['Razas guardianas', 'Socialización temprana', 'Cachorros', 'Mordeduras'],
    isVerified: true,
  ),
  Professional(
    id: 'a09',
    name: 'Sergio Pastor',
    type: ProfessionalType.trainer,
    businessName: 'Canicross Murcia',
    description: 'Adiestrador especializado en deporte con perros: canicross, bikejoring y mushing. Entrenador oficial de la Federación Española de Deportes con Perros.',
    address: 'Calle Salzillo, 8',
    city: 'Murcia',
    phone: '+34 644 220 180',
    email: 'sergio@canicrossmurcia.com',
    website: 'www.canicrossmurcia.com',
    rating: 4.8,
    specialties: ['Canicross', 'Bikejoring', 'Mushing', 'Acondicionamiento físico'],
    isVerified: true,
  ),
  Professional(
    id: 'a10',
    name: 'Cristina Valls',
    type: ProfessionalType.trainer,
    businessName: 'FelisTrainer – Adiestramiento Felino',
    description: 'Una de las pocas entrenadoras especializadas en gatos de España. Resolución de problemas de comportamiento felino: marcaje, agresión y miedo.',
    address: 'Carrer de Provença, 192',
    city: 'Barcelona',
    phone: '+34 611 445 770',
    email: 'cristina@felistrainer.com',
    website: 'www.felistrainer.com',
    rating: 4.9,
    specialties: ['Adiestramiento felino', 'Clicker cats', 'Agresión felina', 'Marcaje'],
    isVerified: true,
  ),
  Professional(
    id: 'a11',
    name: 'Pablo Iglesias',
    type: ProfessionalType.trainer,
    businessName: 'Mente Canina',
    description: 'Adiestrador y divulgador científico. Imparte cursos online y presenciales para profesionales. Colaborador habitual de Animal Político y La Vanguardia.',
    address: 'Calle Núñez de Balboa, 28',
    city: 'Madrid',
    phone: '+34 915 774 390',
    email: 'info@mentecanina.es',
    website: 'www.mentecanina.es',
    rating: 4.9,
    specialties: ['Cursos profesionales', 'Divulgación', 'Online y presencial', 'Ciencia conducta'],
    isVerified: true,
  ),
  Professional(
    id: 'a12',
    name: 'Ana Belén Crespo',
    type: ProfessionalType.trainer,
    businessName: 'TerretaCan Valencia',
    description: 'Especialista en perros adoptados con historial desconocido y perros de razas estigmatizadas. Talleres de convivencia multicanina.',
    address: 'Calle Colón, 56',
    city: 'Valencia',
    phone: '+34 637 881 200',
    email: 'info@terretacan.com',
    website: 'www.terretacan.com',
    rating: 4.7,
    specialties: ['Razas estigmatizadas', 'PPPs', 'Adoptados', 'Convivencia multicanina'],
    isVerified: true,
  ),

  // ══ ETÓLOGOS (adicionales) ════════════════════════════════════════════════

  Professional(
    id: 'e04',
    name: 'Dr. Ignacio Muñoz',
    type: ProfessionalType.ethologist,
    businessName: 'EtoCan Madrid',
    description: 'Veterinario etólogo con especialización en EV ECAWBM y más de 500 casos de ansiedad grave tratados. Pionero en el uso de cámaras de monitoreo conductual en España.',
    address: 'Calle Bravo Murillo, 165',
    city: 'Madrid',
    phone: '+34 912 041 552',
    email: 'ignacio@etocanmadrid.es',
    website: 'www.etocanmadrid.es',
    rating: 4.9,
    specialties: ['Ansiedad grave', 'Monitoreo en casa', 'Farmacología conductual'],
    isVerified: true,
  ),
  Professional(
    id: 'e05',
    name: 'Dra. Beatriz Alonso',
    type: ProfessionalType.ethologist,
    businessName: 'Comportamiento Animal Alonso',
    description: 'Bióloga y etóloga clínica. Especialista en comportamiento de conejos y pequeños mamíferos. La única especialista en lagomorfos reconocida en España.',
    address: 'Calle Sagasta, 24',
    city: 'Valladolid',
    phone: '+34 983 244 711',
    email: 'dra.alonso@etologiavalladolid.es',
    website: 'www.etologiavalladolid.es',
    rating: 4.8,
    specialties: ['Conejos', 'Cobayas', 'Pequeños mamíferos', 'BARF para lagomorfos'],
    isVerified: true,
  ),
  Professional(
    id: 'e06',
    name: 'Dr. Fernando Saura',
    type: ProfessionalType.ethologist,
    businessName: 'Etología Veterinaria Murcia',
    description: 'Profesor del máster en etología de la Universidad de Murcia. Consultas clínicas y segunda opinión para casos complejos de todo España de forma online.',
    address: 'Campus Universitario de Espinardo',
    city: 'Murcia',
    phone: '+34 968 367 002',
    email: 'f.saura@um.es',
    website: 'www.um.es/etologia',
    rating: 4.8,
    specialties: ['Consulta online', 'Segunda opinión', 'Docencia', 'Investigación'],
    isVerified: true,
  ),
  Professional(
    id: 'e07',
    name: 'Marta Benítez',
    type: ProfessionalType.ethologist,
    businessName: 'Ethos Vets Málaga',
    description: 'Veterinaria etóloga especializada en el vínculo humano-animal roto: perros con dueños que se plantean la eutanasia conductual. Enfoque de última oportunidad.',
    address: 'Calle Marqués de Larios, 4',
    city: 'Málaga',
    phone: '+34 952 215 891',
    email: 'marta@ethosvets.es',
    website: 'www.ethosvets.es',
    rating: 5.0,
    specialties: ['Última oportunidad', 'Agresión severa', 'Eutanasia conductual', 'Mediación'],
    isVerified: true,
  ),
  Professional(
    id: 'e08',
    name: 'Dr. Ramón Domínguez',
    type: ProfessionalType.ethologist,
    businessName: 'Ethology Galicia',
    description: 'Etólogo y veterinario en A Coruña. Especialista en comportamiento de perros de pastoreo y razas autóctonas españolas.',
    address: 'Rúa de Compostela, 56',
    city: 'A Coruña',
    phone: '+34 981 223 660',
    email: 'ramon@ethologygalicia.com',
    website: 'www.ethologygalicia.com',
    rating: 4.7,
    specialties: ['Razas autóctonas', 'Perros de pastoreo', 'Instinto de presa', 'Ovejeros'],
    isVerified: true,
  ),

  // ══ NUTRICIONISTAS (adicionales) ══════════════════════════════════════════

  Professional(
    id: 'n04',
    name: 'Dra. Sandra Vega',
    type: ProfessionalType.nutritionist,
    businessName: 'NutriGatos Féline Nutrition',
    description: 'La única nutricionista en España con especialización exclusiva en gatos. Dietas personalizadas para CKD, diabetes y enfermedad inflamatoria intestinal felina.',
    address: 'Calle Gran Vía, 44',
    city: 'Madrid',
    phone: '+34 910 781 200',
    email: 'sandra@nutrigatos.es',
    website: 'www.nutrigatos.es',
    rating: 5.0,
    specialties: ['Nutrición felina', 'CKD felino', 'Diabetes gatuna', 'EII felina'],
    isVerified: true,
  ),
  Professional(
    id: 'n05',
    name: 'Álvaro Rueda',
    type: ProfessionalType.nutritionist,
    businessName: 'DeporteCan Nutrición',
    description: 'Nutricionista especializado en perros de deporte y trabajo. Planes de nutrición para canicross, agility, pastoreo y perros policía.',
    address: 'Calle Virgen de las Nieves, 15',
    city: 'Granada',
    phone: '+34 613 001 882',
    email: 'alvaro@deportecan.com',
    website: 'www.deportecan.com',
    rating: 4.7,
    specialties: ['Deporte canino', 'Alto rendimiento', 'BARF deportivo', 'Suplementación'],
    isVerified: true,
  ),
  Professional(
    id: 'n06',
    name: 'Dra. Pilar Estrada',
    type: ProfessionalType.nutritionist,
    businessName: 'NutriVet Exotic',
    description: 'Doctora en veterinaria y nutricionista especializada en animales exóticos: reptiles, aves psitácidas, conejos y roedores.',
    address: 'Avda. del Mediterráneo, 54',
    city: 'Alicante',
    phone: '+34 965 142 800',
    email: 'pilar@nutrivetexotic.es',
    website: 'www.nutrivetexotic.es',
    rating: 4.9,
    specialties: ['Reptiles', 'Aves psitácidas', 'Conejos', 'Roedores', 'Exóticos'],
    isVerified: true,
  ),
  Professional(
    id: 'n07',
    name: 'Roberto Llamas',
    type: ProfessionalType.nutritionist,
    businessName: 'Nutrición Natural Canina Bilbao',
    description: 'Técnico en nutrición animal y chef de dietas BARF para perros y gatos. Servicio de menús semanales enviados a domicilio en toda España.',
    address: 'Calle Iparraguirre, 22',
    city: 'Bilbao',
    phone: '+34 944 102 340',
    email: 'roberto@nncanina.com',
    website: 'www.nncanina.com',
    rating: 4.6,
    specialties: ['Menús BARF a domicilio', 'Envío nacional', 'Cocina animal'],
    isVerified: false,
  ),
  Professional(
    id: 'n08',
    name: 'Irene Montero',
    type: ProfessionalType.nutritionist,
    businessName: 'Mascotas Longevas',
    description: 'Nutricionista veterinaria especializada en anti-aging y longevidad animal. Diseña protocolos nutricionales para retrasar el envejecimiento en perros y gatos senior.',
    address: 'Calle Alfonso el Magnánimo, 28',
    city: 'Valencia',
    phone: '+34 963 410 102',
    email: 'irene@mascotas longevas.com',
    website: 'www.mascotas-longevas.es',
    rating: 4.8,
    specialties: ['Senior', 'Anti-aging', 'Longevidad', 'Suplementos naturales'],
    isVerified: true,
  ),

  // ══ PELUQUEROS (adicionales) ═══════════════════════════════════════════════

  Professional(
    id: 'p06',
    name: 'Javier Morales',
    type: ProfessionalType.groomer,
    businessName: 'Élite Canine Grooming',
    description: 'Peluquero especializado en perros de exposición. Ha preparado a campeones de España en razas como el Bichón Frisé, el Poodle toy y el Yorkshire Terrier.',
    address: 'Calle Velázquez, 92',
    city: 'Madrid',
    phone: '+34 914 313 820',
    email: 'javier@elitecanine.es',
    website: 'www.elitecanine.es',
    rating: 4.9,
    specialties: ['Exposición/Show', 'Poodle', 'Yorkshire', 'Bichón Frisé', 'Bóxer'],
    isVerified: true,
  ),
  Professional(
    id: 'p07',
    name: 'Margarita Reyes',
    type: ProfessionalType.groomer,
    businessName: 'Toeletta Canina de Margarita',
    description: 'Peluquería canina en Sevilla con 20 años de experiencia. Especialista en cortes creativos y Body Painting canino no tóxico para concursos y eventos.',
    address: 'Calle Feria, 48',
    city: 'Sevilla',
    phone: '+34 955 389 210',
    email: 'margarita@toelettacanina.com',
    website: 'www.toelettacanina.com',
    rating: 4.7,
    specialties: ['Creative grooming', 'Body painting', 'Concursos', 'Cortes artísticos'],
    isVerified: true,
  ),
  Professional(
    id: 'p08',
    name: 'Cristóbal Herrera',
    type: ProfessionalType.groomer,
    businessName: 'Nordic Dog Grooming',
    description: 'Peluquero especializado en razas nórdicas: Samoyedo, Malamute, Husky Siberiano y Chow Chow. Baños de spa para mantenimiento del subpelo.',
    address: 'Calle Dr. Fleming, 31',
    city: 'Zaragoza',
    phone: '+34 976 448 801',
    email: 'cristobal@nordicdoggrooming.es',
    website: 'www.nordicdoggrooming.es',
    rating: 4.8,
    specialties: ['Razas nórdicas', 'Husky', 'Samoyedo', 'Malamute', 'Cepillado subpelo'],
    isVerified: true,
  ),
  Professional(
    id: 'p09',
    name: 'Sonia Prats',
    type: ProfessionalType.groomer,
    businessName: 'Peluquería Canina Vintage',
    description: 'Peluquería artesanal en Girona. Usa únicamente productos orgánicos y libres de parabenos, sulfatos y fragancias artificiales. Masajes incluidos en todos los servicios.',
    address: 'Carrer de la Força, 22',
    city: 'Girona',
    phone: '+34 972 211 770',
    email: 'sonia@peluqueriacaninavintage.com',
    website: 'www.peluqueriacaninavintage.com',
    rating: 4.9,
    specialties: ['Productos orgánicos', 'Masajes', 'Cero químicos agresivos', 'Piel sensible'],
    isVerified: true,
  ),
  Professional(
    id: 'p10',
    name: 'Héctor Vargas',
    type: ProfessionalType.groomer,
    businessName: 'Grooming Express',
    description: 'Servicio de peluquería canina a domicilio en toda la provincia de Madrid. Furgoneta equipada con bañera hidromasa, secador de alta potencia y mesa de trabajo.',
    address: 'Servicio a domicilio – Provincia de Madrid',
    city: 'Madrid',
    phone: '+34 633 872 241',
    email: 'hector@groomingexpress.es',
    website: 'www.groomingexpress.es',
    rating: 4.8,
    specialties: ['A domicilio', 'Toda la provincia', 'Furgoneta equipada', 'Sin estrés desplazamiento'],
    isVerified: true,
  ),

  // ══ PET FRIENDLY adicionales – Bares y Restaurantes ═══════════════════════

  Professional(
    id: 'pf17',
    name: 'El Perro y La Galleta',
    type: ProfessionalType.petFriendly,
    businessName: 'El Perro y La Galleta',
    description: 'Cafetería de especialidad en café en Madrid que permite perros dentro. Tienen una selección de snacks y galletas horneadas para mascotas.',
    address: 'Calle Manuela Malasaña, 9',
    city: 'Madrid',
    phone: '+34 915 211 304',
    email: 'hola@elperroylgalleta.es',
    website: 'www.elperroylgalleta.es',
    rating: 4.8,
    specialties: ['Dentro dog-friendly', 'Café especialidad', 'Snacks horneados', 'Sin correa obligatoria'],
    isVerified: true,
  ),
  Professional(
    id: 'pf18',
    name: 'Bar Canario',
    type: ProfessionalType.petFriendly,
    businessName: 'Bar Canario Las Palmas',
    description: 'Bar histórico de Las Palmas de Gran Canaria. Amplia terraza donde los perros siempre han sido bienvenidos. Conocido por sus papas arrugadas y mojo.',
    address: 'Calle Mesa y López, 18',
    city: 'Las Palmas de Gran Canaria',
    phone: '+34 928 361 210',
    email: 'info@barcanario.com',
    website: 'www.barcanario.com',
    rating: 4.5,
    specialties: ['Terraza dog-friendly', 'Cocina canaria', 'Perros de cualquier tamaño'],
    isVerified: true,
  ),
  Professional(
    id: 'pf19',
    name: 'La Gastroteca de Santiago',
    type: ProfessionalType.petFriendly,
    businessName: 'La Gastroteca de Santiago',
    description: 'Restaurante gallego de autor en Madrid. Terraza cerrada y climatizada donde los perros son bienvenidos todo el año, con agua y snack de cortesía.',
    address: 'Plaza de Santiago, 1',
    city: 'Madrid',
    phone: '+34 915 481 232',
    email: 'reservas@lagastroteca.es',
    website: 'www.lagastroteca.es',
    rating: 4.7,
    specialties: ['Terraza cerrada/climatizada', 'Todo el año', 'Snack cortesía', 'Cocina gallega'],
    isVerified: true,
  ),
  Professional(
    id: 'pf20',
    name: 'Cervecería La Oficial',
    type: ProfessionalType.petFriendly,
    businessName: 'La Oficial Craft Beer',
    description: 'Cervecería artesanal en Bilbao con terraza cubierta dog-friendly. Amplia selección de cervezas artesanas y pintxos. Los perros reciben agua y golosina al llegar.',
    address: 'Calle Ledesma, 8',
    city: 'Bilbao',
    phone: '+34 944 150 390',
    email: 'info@laoficialbilbao.com',
    website: 'www.laoficialbilbao.com',
    rating: 4.6,
    specialties: ['Terraza cubierta', 'Craft beer', 'Pintxos', 'Agua + golosina bienvenida'],
    isVerified: true,
  ),
  Professional(
    id: 'pf21',
    name: 'Surfers The Bar',
    type: ProfessionalType.petFriendly,
    businessName: 'Surfers The Bar',
    description: 'Bar de playa en Tarifa completamente dog-friendly. La mayoría de clientes llegan con perro. Zona de arena cercada y ducha para perros al salir del mar.',
    address: 'Playa de los Lances s/n',
    city: 'Tarifa (Cádiz)',
    phone: '+34 956 680 788',
    email: 'info@surferstarifa.com',
    website: 'www.surferstarifa.com',
    rating: 4.9,
    specialties: ['Playa dog-friendly', 'Ducha para perros', 'Surf y kite', 'Todos los días'],
    isVerified: true,
  ),

  // ══ PET FRIENDLY adicionales – Hoteles y Alojamientos ══════════════════════

  Professional(
    id: 'pf22',
    name: 'Hotel Vincci Soho',
    type: ProfessionalType.petFriendly,
    businessName: 'Vincci Soho Madrid',
    description: 'Hotel boutique de 4 estrellas en el barrio de las Letras de Madrid. Admite mascotas de hasta 8 kg con cama, cuencos y mapa de paseos cercanos.',
    address: 'Calle Prado, 18',
    city: 'Madrid',
    phone: '+34 914 001 610',
    email: 'soho@vinccihoteles.com',
    website: 'www.vinccihoteles.com',
    rating: 4.5,
    specialties: ['Boutique', '4 estrellas', 'Hasta 8 kg', 'Mapa de paseos'],
    isVerified: true,
  ),
  Professional(
    id: 'pf23',
    name: 'Finca Cortesín Hotel & Golf',
    type: ProfessionalType.petFriendly,
    businessName: 'Finca Cortesín',
    description: 'Resort de lujo de 5 estrellas en la Costa del Sol con 200 hectáreas. Perros bienvenidos en bungalows y villas con jardín privado. Servicio de paseo y guardería.',
    address: 'Ctra. de Casares s/n',
    city: 'Casares (Málaga)',
    phone: '+34 952 937 800',
    email: 'info@fincacortesin.com',
    website: 'www.fincacortesin.com',
    rating: 4.9,
    specialties: ['5 estrellas', '200 ha', 'Bungalows con jardín', 'Guardería canina', 'Golf'],
    isVerified: true,
  ),
  Professional(
    id: 'pf24',
    name: 'Hospes Palau de la Mar',
    type: ProfessionalType.petFriendly,
    businessName: 'Hospes Palau de la Mar Valencia',
    description: 'Hotel de 5 estrellas en un palacete del s.XIX en Valencia. Perros admitidos en habitaciones deluxe y suites. Kit de bienvenida para mascotas.',
    address: 'Navarro Reverter, 14',
    city: 'Valencia',
    phone: '+34 963 162 884',
    email: 'palaudelamar@hospes.com',
    website: 'www.hospes.com',
    rating: 4.8,
    specialties: ['Palacete histórico', '5 estrellas', 'Kit bienvenida', 'Habitaciones deluxe'],
    isVerified: true,
  ),
  Professional(
    id: 'pf25',
    name: 'AC Hotel by Marriott Málaga Palacio',
    type: ProfessionalType.petFriendly,
    businessName: 'AC Málaga Palacio',
    description: 'Hotel céntrico de 4 estrellas en Málaga con vistas a la Alcazaba. Admite perros de hasta 25 kg sin suplemento adicional.',
    address: 'Cortina del Muelle, 1',
    city: 'Málaga',
    phone: '+34 952 215 185',
    email: 'ac.malaga.palacio@marriott.com',
    website: 'www.marriott.com',
    rating: 4.6,
    specialties: ['Hasta 25 kg', 'Sin suplemento', 'Vistas Alcazaba', '4 estrellas'],
    isVerified: true,
  ),

  // ══ PET FRIENDLY adicionales – Tiendas y Espacios ═════════════════════════

  Professional(
    id: 'pf26',
    name: 'Ikea Badalona',
    type: ProfessionalType.petFriendly,
    businessName: 'IKEA Badalona',
    description: 'El IKEA de Badalona ha habilitado una zona de parking especial y el acceso con perros en carrito o bolsa de transporte en ciertas zonas del establecimiento.',
    address: 'Avda. de la Unitat, 2',
    city: 'Badalona (Barcelona)',
    phone: '+34 932 780 200',
    email: 'atencioncliente@ikea.com',
    website: 'www.ikea.es',
    rating: 4.1,
    specialties: ['Zona parking canina', 'Perros en carrito/bolsa', 'Zona exterior'],
    isVerified: false,
  ),
  Professional(
    id: 'pf27',
    name: 'Decathlon',
    type: ProfessionalType.petFriendly,
    businessName: 'Decathlon – Tiendas seleccionadas',
    description: 'Muchas tiendas Decathlon en España admiten perros bien educados con correa. Política no oficial pero extendida. Recomendable llamar a la tienda antes de ir.',
    address: 'Calle Chile, 1',
    city: 'Madrid',
    phone: '+34 902 300 700',
    email: 'atencioncliente@decathlon.es',
    website: 'www.decathlon.es',
    rating: 4.3,
    specialties: ['Perros con correa', 'Política informal', 'Llamar antes', 'Deportes con perro'],
    isVerified: false,
  ),
  Professional(
    id: 'pf28',
    name: 'Parque de El Retiro',
    type: ProfessionalType.petFriendly,
    businessName: 'Parque del Buen Retiro – Madrid',
    description: 'El parque más emblemático de Madrid admite perros con correa en todas sus zonas. Existen áreas de esparcimiento canino sin correa en zonas delimitadas.',
    address: 'Plaza de la Independencia, 7',
    city: 'Madrid',
    phone: '+34 915 881 000',
    email: 'parques@madrid.es',
    website: 'www.madrid.es/retiro',
    rating: 4.8,
    specialties: ['Zona sin correa', 'Todo el parque', 'Fuentes para perros', 'Sombra'],
    isVerified: true,
  ),
  Professional(
    id: 'pf29',
    name: 'Parque de la Ciutadella',
    type: ProfessionalType.petFriendly,
    businessName: 'Parc de la Ciutadella – Barcelona',
    description: 'El pulmón verde de Barcelona acepta perros en todo el parque con correa. Puntos de agua para mascotas y zona específica de esparcimiento canino.',
    address: 'Passeig de Picasso, s/n',
    city: 'Barcelona',
    phone: '+34 932 564 120',
    email: 'parcs@bcn.cat',
    website: 'www.barcelona.cat',
    rating: 4.7,
    specialties: ['Zona sin correa', 'Fuentes caninas', 'Sombra', 'Lago con barcas'],
    isVerified: true,
  ),
  Professional(
    id: 'pf30',
    name: 'Media Markt',
    type: ProfessionalType.petFriendly,
    businessName: 'Media Markt – Centros seleccionados',
    description: 'Algunos centros Media Markt en España permiten la entrada de perros en bolsa de transporte o carrito. Política variable por centro. Consultar antes de ir.',
    address: 'Ctra. de la Playa s/n',
    city: 'Palma de Mallorca',
    phone: '+34 902 533 533',
    email: 'atencioncliente@mediamarkt.es',
    website: 'www.mediamarkt.es',
    rating: 3.9,
    specialties: ['Perros en carrito/bolsa', 'Consultar por centro', 'Política variable'],
    isVerified: false,
  ),
];

