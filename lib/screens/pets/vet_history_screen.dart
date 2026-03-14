import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:nachos_pet_care_flutter/models/veterinary_report.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';

class VetHistoryScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const VetHistoryScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<VetHistoryScreen> createState() => _VetHistoryScreenState();
}

class _VetHistoryScreenState extends State<VetHistoryScreen> {
  final DatabaseService _db = getIt<DatabaseService>();
  List<VeterinaryReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await _db.getVeterinaryReportsByPet(widget.petId);
      if (mounted) setState(() => _reports = reports);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar historial: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addReport() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ReportForm(
        petId: widget.petId,
        onSaved: () {
          Navigator.pop(ctx);
          _loadReports();
        },
      ),
    );
  }

  Future<void> _deleteReport(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar visita?'),
        content: const Text('Se eliminará este registro veterinario.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deleteVeterinaryReport(id);
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial · ${widget.petName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/pets/${widget.petId}');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReport,
        icon: const Icon(Icons.add),
        label: const Text('Añadir visita'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medical_services, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Sin visitas registradas',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pulsa + para añadir una visita veterinaria',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final r = _reports[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.medical_services, size: 20),
                        ),
                        title: Text(
                          r.vetName?.isNotEmpty == true
                              ? 'Dr. ${r.vetName}'
                              : 'Visita veterinaria',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(r.visitDate)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteReport(r.id),
                            ),
                            const Icon(Icons.expand_more),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (r.diagnosis != null && r.diagnosis!.isNotEmpty)
                                  _DetailRow(label: 'Diagnóstico', value: r.diagnosis!),
                                if (r.treatment != null && r.treatment!.isNotEmpty)
                                  _DetailRow(label: 'Tratamiento', value: r.treatment!),
                                if (r.notes != null && r.notes!.isNotEmpty)
                                  _DetailRow(label: 'Notas', value: r.notes!),
                              ],
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _ReportForm extends StatefulWidget {
  final String petId;
  final VoidCallback onSaved;

  const _ReportForm({required this.petId, required this.onSaved});

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _vetNameController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _visitDate = DateTime.now();
  final DatabaseService _db = getIt<DatabaseService>();
  bool _saving = false;

  @override
  void dispose() {
    _vetNameController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final report = VeterinaryReport(
        id: const Uuid().v4(),
        petId: widget.petId,
        visitDate: _visitDate,
        vetName: _vetNameController.text.trim().isEmpty ? null : _vetNameController.text.trim(),
        diagnosis: _diagnosisController.text.trim().isEmpty ? null : _diagnosisController.text.trim(),
        treatment: _treatmentController.text.trim().isEmpty ? null : _treatmentController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );
      await _db.insertVeterinaryReport(report);
      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nueva visita veterinaria', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha de la visita *'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_visitDate)),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _visitDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _visitDate = d);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _vetNameController,
              decoration: const InputDecoration(
                labelText: 'Veterinario (opcional)',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Diagnóstico (opcional)',
                prefixIcon: Icon(Icons.sick),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _treatmentController,
              decoration: const InputDecoration(
                labelText: 'Tratamiento (opcional)',
                prefixIcon: Icon(Icons.medication),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar visita'),
            ),
          ],
        ),
      ),
    );
  }
}
