import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nachos_pet_care_flutter/models/vet_invitation.dart';
import 'package:nachos_pet_care_flutter/services/vet_clinic_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/l10n/app_strings.dart';

class VetDashboardScreen extends StatefulWidget {
  const VetDashboardScreen({super.key});

  @override
  State<VetDashboardScreen> createState() => _VetDashboardScreenState();
}

class _VetDashboardScreenState extends State<VetDashboardScreen> {
  final VetClinicService _vetService = getIt<VetClinicService>();
  int _activeTabIdx = 0;
  bool _isSaaSActive = false;

  @override
  void initState() {
    super.initState();
    _checkSaaSStatus();
  }

  Future<void> _checkSaaSStatus() async {
    final active = await _vetService.isSaaSActive();
    setState(() => _isSaaSActive = active);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.local_hospital_rounded, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text(
              'Nachos B2B Clínicas 🩺',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _isSaaSActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isSaaSActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isSaaSActive ? Icons.check_circle : Icons.warning_amber_rounded,
                  size: 14,
                  color: _isSaaSActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  _isSaaSActive ? 'SaaS Activo (49 €/mes)' : 'SaaS Inactivo',
                  style: TextStyle(
                    color: _isSaaSActive ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // ── Lateral Sidebar (Para Pantallas Desktop) ─────────────────────
          if (isDesktop)
            Container(
              width: 250,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: colorScheme.primary.withOpacity(0.08)),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildSidebarItem(0, 'Consola General', Icons.dashboard_outlined),
                  _buildSidebarItem(1, 'Pacientes Compartidos', Icons.people_outline),
                  _buildSidebarItem(2, 'Licencia SaaS B2B', Icons.card_membership_outlined),
                  _buildSidebarItem(3, 'Desarrolladores & API', Icons.code_rounded),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'v3.0.0 B2B Ecosistema',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.4)),
                    ),
                  ),
                ],
              ),
            ),

          // ── Contenido Principal de Pestaña Activa ───────────────────────
          Expanded(
            child: _buildActiveTabContent(),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: _activeTabIdx,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurface.withOpacity(0.4),
              showUnselectedLabels: true,
              onTap: (idx) => setState(() => _activeTabIdx = idx),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Resumen'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pacientes'),
                BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'SaaS'),
                BottomNavigationBarItem(icon: Icon(Icons.code), label: 'API'),
              ],
            )
          : null,
    );
  }

  Widget _buildSidebarItem(int index, String title, IconData icon) {
    final active = _activeTabIdx == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: active ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        selected: active,
        selectedTileColor: colorScheme.primary.withOpacity(0.06),
        onTap: () => setState(() => _activeTabIdx = index),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTabIdx) {
      case 0:
        return _VetOverviewTab(isSaaSActive: _isSaaSActive);
      case 1:
        return _VetPatientsTab(isSaaSActive: _isSaaSActive);
      case 2:
        return _VetSaaSTab(
          isSaaSActive: _isSaaSActive,
          onStatusChanged: (active) => setState(() => _isSaaSActive = active),
        );
      case 3:
        return const _VetAPITab();
      default:
        return const Center(child: Text('Panel no encontrado'));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 📊 PESTAÑA 1: CONSOLA GENERAL (OVERVIEW)
// ─────────────────────────────────────────────────────────────────────────────
class _VetOverviewTab extends StatelessWidget {
  final bool isSaaSActive;
  final VetClinicService _vetService = getIt<VetClinicService>();

  _VetOverviewTab({required this.isSaaSActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<List<VetInvitation>>(
      stream: _vetService.invitationsStream,
      initialData: const [],
      builder: (context, snapshot) {
        final list = snapshot.data ?? [];
        final accepted = list.where((i) => i.status == 'accepted').length;
        final pending = list.where((i) => i.status == 'pending').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consola de Administración',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Bienvenido al centro clínico de Nachos PetCare. Supervisa tus pacientes e integraciones API.',
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 24),

              // ── Cuadrícula de Indicadores SaaS / B2B ────────────────────────
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    context,
                    'Estado del SaaS',
                    isSaaSActive ? 'Licencia Activa' : 'Suscripción Req.',
                    isSaaSActive ? '49 €/mes renovando' : 'Contrata el plan B2B',
                    isSaaSActive ? Colors.green : Colors.red,
                    isSaaSActive ? Icons.verified_user : Icons.cancel_outlined,
                  ),
                  _buildStatCard(
                    context,
                    'Pacientes Activos',
                    '$accepted',
                    'Mascotas con acceso',
                    colorScheme.primary,
                    Icons.pets_rounded,
                  ),
                  _buildStatCard(
                    context,
                    'Invitaciones Pendientes',
                    '$pending',
                    'Handshake por aceptar',
                    Colors.orange,
                    Icons.hourglass_bottom_rounded,
                  ),
                  StreamBuilder<int>(
                    stream: _vetService.apiCounterStream,
                    initialData: 482,
                    builder: (context, apiSnap) {
                      final count = apiSnap.data ?? 482;
                      return _buildStatCard(
                        context,
                        'Peticiones API',
                        '$count',
                        'Total llamadas REST',
                        Colors.teal,
                        Icons.settings_ethernet_rounded,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Actividad Reciente y Gráfico Ficticio ────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Evolución de Consultas Médicas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          // Representación gráfica minimalista muy premium
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBarChartColumn(context, 'Ene', 45, false),
                              _buildBarChartColumn(context, 'Feb', 60, false),
                              _buildBarChartColumn(context, 'Mar', 85, false),
                              _buildBarChartColumn(context, 'Abr', 110, false),
                              _buildBarChartColumn(context, 'May', 150, true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 900) ...[
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Logs de Actividad B2B', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            _buildActivityRow(context, 'Mascota Vinculada', 'Nachito fue añadido por Juan Pérez.', 'Hace 1 hora'),
                            _buildActivityRow(context, 'Licencia SaaS', 'Pago mensual de 49€ procesado.', 'Ayer'),
                            _buildActivityRow(context, 'Playground API', 'Petición GET /patients resuelta 200 OK.', 'Hace 2 días'),
                          ],
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.5))),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartColumn(BuildContext context, String label, double val, bool highlight) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 24,
          height: val,
          decoration: BoxDecoration(
            color: highlight ? colorScheme.primary : colorScheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActivityRow(BuildContext context, String title, String desc, String time) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fiber_manual_record, size: 10, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 11)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 👥 PESTAÑA 2: PACIENTES COMPARTIDOS
// ─────────────────────────────────────────────────────────────────────────────
class _VetPatientsTab extends StatefulWidget {
  final bool isSaaSActive;
  const _VetPatientsTab({required this.isSaaSActive});

  @override
  State<_VetPatientsTab> createState() => _VetPatientsTabState();
}

class _VetPatientsTabState extends State<_VetPatientsTab> {
  final VetClinicService _vetService = getIt<VetClinicService>();
  String _searchQuery = '';
  VetInvitation? _selectedPatient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!widget.isSaaSActive) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: colorScheme.primary.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text(
                'Módulo SaaS Bloqueado',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Necesitas contratar la suscripción SaaS B2B de la clínica (49 €/mes) en la pestaña "Licencia SaaS" para gestionar pacientes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<List<VetInvitation>>(
      stream: _vetService.invitationsStream,
      initialData: const [],
      builder: (context, snapshot) {
        final list = snapshot.data ?? [];
        final filtered = list.where((inv) {
          final query = _searchQuery.toLowerCase();
          return inv.petName.toLowerCase().contains(query) ||
              inv.ownerName.toLowerCase().contains(query);
        }).toList();

        return Row(
          children: [
            // ── Lista de Pacientes e Invitaciones Pendientes ────────────────
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar por mascota o dueño...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, idx) {
                        final inv = filtered[idx];
                        final isSelected = _selectedPatient?.id == inv.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? colorScheme.primary.withOpacity(0.06) : colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? colorScheme.primary : colorScheme.primary.withOpacity(0.08),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: inv.petPhoto != null && inv.petPhoto!.startsWith('http')
                                  ? NetworkImage(inv.petPhoto!)
                                  : null,
                              child: inv.petPhoto == null ? const Icon(Icons.pets) : null,
                            ),
                            title: Text(inv.petName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Dueño: ${inv.ownerName}'),
                            trailing: inv.status == 'pending'
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () => _vetService.updateInvitationStatus(inv.id, 'accepted'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () => _vetService.updateInvitationStatus(inv.id, 'declined'),
                                      ),
                                    ],
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Aceptado',
                                      style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                            onTap: () {
                              if (inv.status == 'accepted') {
                                setState(() => _selectedPatient = inv);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // ── Detalle / Ficha Médica del Paciente Seleccionado ──────────────
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: colorScheme.primary.withOpacity(0.08))),
                ),
                child: _selectedPatient == null
                    ? const Center(child: Text('Selecciona un paciente aceptado para ver su historial clínico.'))
                    : _buildPatientDetailCard(_selectedPatient!),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPatientDetailCard(VetInvitation patient) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: patient.petPhoto != null && patient.petPhoto!.startsWith('http')
                    ? NetworkImage(patient.petPhoto!)
                    : null,
                child: patient.petPhoto == null ? const Icon(Icons.pets, size: 36) : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.petName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Propietario: ${patient.ownerName}', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Vacunas Registradas ───────────────────────────────────────────
          Text('Cartilla de Vacunación', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                _buildVaccineItem('Antirrábica Canina', '15 May 2026', true),
                const Divider(),
                _buildVaccineItem('Trivalente Felina', '20 Ago 2026', false),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Historial Clínico de Visitas ──────────────────────────────────
          Text('Historial Clínico Reciente', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildClinicalReportCard(
            'Dr. Alejandro Méndez',
            '27 Abr 2026',
            'Control Anual',
            'Paciente saludable. Pelaje brillante, oídos limpios. Vacunación completa.',
            'Ninguno en particular.',
          ),
          const SizedBox(height: 12),
          _buildClinicalReportCard(
            'Dra. Sofía Rivas',
            '10 Ene 2026',
            'Revisión Digestiva',
            'Leve intolerancia alimentaria por ingesta inapropiada.',
            'Dieta blanda y probióticos durante 5 días.',
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineItem(String name, String date, bool completed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.shield_outlined, color: completed ? Colors.green : Colors.orange, size: 20),
            const SizedBox(width: 12),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        Text(
          completed ? 'Completado ($date)' : 'Próxima ($date)',
          style: TextStyle(
            color: completed ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildClinicalReportCard(
    String vet,
    String date,
    String diagnosis,
    String desc,
    String treatment,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(vet, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(date, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Diagnóstico: $diagnosis', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 12)),
          const SizedBox(height: 8),
          Text('Tratamiento: $treatment', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 💳 PESTAÑA 3: LICENCIA SAAS B2B (CHECKOUT SIMULATION)
// ─────────────────────────────────────────────────────────────────────────────
class _VetSaaSTab extends StatefulWidget {
  final bool isSaaSActive;
  final Function(bool active) onStatusChanged;

  const _VetSaaSTab({required this.isSaaSActive, required this.onStatusChanged});

  @override
  State<_VetSaaSTab> createState() => _VetSaaSTabState();
}

class _VetSaaSTabState extends State<_VetSaaSTab> {
  final VetClinicService _vetService = getIt<VetClinicService>();
  bool _loading = false;

  void _simulatePurchase() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2)); // Latencia simulada de banco
    await _vetService.setSaaSActive(true);
    widget.onStatusChanged(true);
    setState(() => _loading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('¡Suscripción Activada! 🎉'),
          content: const Text('La licencia SaaS B2B de tu clínica veterinaria (49 €/mes) se ha activado con éxito. Ya puedes gestionar todos tus pacientes compartidos y utilizar las APIs REST.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  void _simulateCancel() async {
    await _vetService.setSaaSActive(false);
    widget.onStatusChanged(false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Suscripción cancelada correctamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Licencia SaaS B2B Clínicas', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text('Adquiere el plan profesional B2B para integrar tus bases de datos y dar acceso a tus veterinarios.', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tarjeta de Precios B2B ──────────────────────────────────
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colorScheme.primary, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text('CLÍNICA PROFESIONAL', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('49 €', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                          Text('/mes', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildBulletItem('Gestión ilimitada de pacientes invitados'),
                      _buildBulletItem('Acceso completo al Portal Clínico Web'),
                      _buildBulletItem('API REST Pública con generación de claves de acceso'),
                      _buildBulletItem('Soporte técnico preferente 24/7'),
                      const SizedBox(height: 32),
                      if (widget.isSaaSActive)
                        ElevatedButton(
                          onPressed: _simulateCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text('Cancelar Suscripción SaaS', style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      else
                        ElevatedButton(
                          onPressed: _loading ? null : _simulatePurchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: _loading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Contratar Licencia SaaS', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              
              // ── Pasarela Simulada / Historial de Facturación ───────────────
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Historial de Facturación', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (widget.isSaaSActive) ...[
                        _buildInvoiceRow('Factura #NC-2026-05', '17 May 2026', '49.00 €', 'Pagado'),
                        const Divider(),
                        _buildInvoiceRow('Factura #NC-2026-04', '17 Abr 2026', '49.00 €', 'Pagado'),
                        const Divider(),
                        _buildInvoiceRow('Factura #NC-2026-03', '17 Mar 2026', '49.00 €', 'Pagado'),
                      ] else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text('No hay facturas registradas. Contrata el plan para ver tu historial.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String code, String date, String price, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(date, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 11)),
            ],
          ),
          Row(
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('PAGADO', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 💻 PESTAÑA 4: DESARROLLADORES Y API REST (PLAYGROUND / SANDBOX)
// ─────────────────────────────────────────────────────────────────────────────
class _VetAPITab extends StatefulWidget {
  const _VetAPITab();

  @override
  State<_VetAPITab> createState() => _VetAPITabState();
}

class _VetAPITabState extends State<_VetAPITab> {
  final VetClinicService _vetService = getIt<VetClinicService>();
  List<Map<String, dynamic>> _apiKeys = [];
  
  // Playground state
  String _selectedEndpoint = '/api/v1/patients';
  String _inputClientId = '';
  String _inputClientSecret = '';
  String _terminalOutput = '';
  bool _executing = false;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    final keys = await _vetService.getApiKeys();
    setState(() {
      _apiKeys = List.from(keys);
      if (_apiKeys.isNotEmpty) {
        _inputClientId = _apiKeys.first['clientId'] ?? '';
        _inputClientSecret = _apiKeys.first['clientSecret'] ?? '';
      }
    });
  }

  void _generateNewKey() async {
    await _vetService.generateApiKey('Clave de Integración #${_apiKeys.length + 1}');
    _loadApiKeys();
  }

  void _executePlaygroundRequest() async {
    if (_inputClientId.isEmpty || _inputClientSecret.isEmpty) {
      setState(() => _terminalOutput = 'Error: Por favor, introduce tu Client ID y Client Secret.');
      return;
    }

    setState(() {
      _executing = true;
      _terminalOutput = '>>> INICIANDO SOLICITUD REST API...\n'
          '>>> GET $_selectedEndpoint HTTP/1.1\n'
          '>>> Host: api.nachospetcare.com\n'
          '>>> Authorization: Bearer $_inputClientId:$_inputClientSecret\n'
          '>>> Enviando petición a los servidores públicos...\n\n';
    });

    final res = await _vetService.simulateApiRequest(
      clientId: _inputClientId,
      clientSecret: _inputClientSecret,
      endpoint: _selectedEndpoint,
    );

    // Formatear JSON
    final status = res['status'] as int;
    final bodyStr = JsonEncoder.withIndent('  ').convert(res['body']);

    setState(() {
      _terminalOutput += '<<< RESPUESTA RECIBIDA (HTTP/1.1 $status ${status == 200 ? "OK" : "Error"})\n'
          '<<< Content-Type: application/json\n'
          '<<< Server: Nachos-API-v3\n\n'
          '$bodyStr';
      _executing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Desarrolladores & API REST Pública', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text('Integra la base de datos de tu clínica con tu propio software ERP/CRM utilizando nuestra API REST pública.', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 32),

          // 🔑 1. Sección de Claves de Acceso API
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Credenciales API REST', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: _generateNewKey,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Generar API Key'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_apiKeys.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Aún no has generado claves de API.')),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _apiKeys.length,
                    itemBuilder: (context, idx) {
                      final key = _apiKeys[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(key['name'] ?? 'Clave API', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Client ID: ${key['clientId']}', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: colorScheme.onSurface.withOpacity(0.7))),
                                  Text('Client Secret: ${key['clientSecret']}', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: colorScheme.onSurface.withOpacity(0.7))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _vetService.deleteApiKey(key['clientId']);
                                _loadApiKeys();
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 💻 2. Sandbox Interactiva (Playground REST API)
          Text('Sandbox Interactiva de Pruebas', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text('Pon a prueba tus llamadas de API directamente en nuestra terminal interactiva en tiempo real.', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🛠️ Panel de Configuración de Consulta
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Configuración del Playground', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      // Endpoint Select
                      const Text('Endpoint:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedEndpoint,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: '/api/v1/patients', child: Text('GET /api/v1/patients')),
                          DropdownMenuItem(value: '/api/v1/patients/pet_nachito/medical-records', child: Text('GET /api/v1/patients/pet_nachito/medical-records')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedEndpoint = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Client ID
                      const Text('Client ID:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _inputClientId,
                        decoration: InputDecoration(
                          hintText: 'cli_nachos_...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) => _inputClientId = val,
                      ),
                      const SizedBox(height: 16),

                      // Client Secret
                      const Text('Client Secret:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _inputClientSecret,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'sec_nachos_...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) => _inputClientSecret = val,
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _executing ? null : _executePlaygroundRequest,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: _executing
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Ejecutar Petición 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // 🖥️ Terminal de Output JSON
              Expanded(
                flex: 3,
                child: Container(
                  height: 380,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.content_copy, color: Colors.white70, size: 18),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _terminalOutput));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Salida de terminal copiada al portapapeles.')),
                              );
                            },
                          )
                        ],
                      ),
                      const Divider(color: Colors.white12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _terminalOutput.isEmpty
                              ? '>>> Terminal lista. Configura tu consulta a la izquierda y presiona "Ejecutar Petición" para realizar una solicitud REST simulada.'
                              : _terminalOutput,
                            style: const TextStyle(
                              color: Color(0xFF00FF00),
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
