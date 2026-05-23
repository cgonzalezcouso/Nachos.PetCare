import 'package:flutter/material.dart';
import 'package:nachos_pet_care_flutter/models/professional.dart';
import 'package:nachos_pet_care_flutter/data/professionals_data.dart';
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
    var list = allProfessionals();
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
