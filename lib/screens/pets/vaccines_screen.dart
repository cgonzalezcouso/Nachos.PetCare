import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:nachos_pet_care_flutter/models/vaccine_reminder.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';

class VaccinesScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const VaccinesScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  final DatabaseService _db = getIt<DatabaseService>();
  List<VaccineReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final reminders = await _db.getVaccineRemindersByPet(widget.petId);
      if (mounted) setState(() => _reminders = reminders);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar vacunas: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addReminder() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _VaccineForm(
        petId: widget.petId,
        onSaved: () {
          Navigator.pop(ctx);
          _loadReminders();
        },
      ),
    );
  }

  Future<void> _toggleCompleted(VaccineReminder reminder) async {
    final updated = reminder.copyWith(completed: !reminder.completed);
    await _db.updateVaccineReminder(updated);
    _loadReminders();
  }

  Future<void> _deleteReminder(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar vacuna?'),
        content: const Text('Se eliminará este recordatorio de vacuna.'),
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
      await _db.deleteVaccineReminder(id);
      _loadReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vacunas · ${widget.petName}'),
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
        onPressed: _addReminder,
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.vaccines, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Sin vacunas registradas',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pulsa + para añadir un recordatorio',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final r = _reminders[index];
                    final overdue = !r.completed && r.dueDate.isBefore(DateTime.now());
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Checkbox(
                          value: r.completed,
                          onChanged: (_) => _toggleCompleted(r),
                        ),
                        title: Text(
                          r.vaccineName,
                          style: TextStyle(
                            decoration: r.completed ? TextDecoration.lineThrough : null,
                            color: r.completed ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 13,
                                  color: overdue ? Colors.red : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(r.dueDate),
                                  style: TextStyle(
                                    color: overdue ? Colors.red : null,
                                    fontWeight: overdue ? FontWeight.bold : null,
                                  ),
                                ),
                                if (overdue) ...[
                                  const SizedBox(width: 6),
                                  const Text(
                                    'VENCIDA',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (r.notes != null && r.notes!.isNotEmpty)
                              Text(r.notes!, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteReminder(r.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _VaccineForm extends StatefulWidget {
  final String petId;
  final VoidCallback onSaved;

  const _VaccineForm({required this.petId, required this.onSaved});

  @override
  State<_VaccineForm> createState() => _VaccineFormState();
}

class _VaccineFormState extends State<_VaccineForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  final DatabaseService _db = getIt<DatabaseService>();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final reminder = VaccineReminder(
        id: const Uuid().v4(),
        petId: widget.petId,
        vaccineName: _nameController.text.trim(),
        dueDate: _dueDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );
      await _db.insertVaccineReminder(reminder);
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
    return Padding(
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
            Text('Nueva vacuna', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la vacuna *',
                prefixIcon: Icon(Icons.vaccines),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha de próxima dosis'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_dueDate)),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _dueDate = d);
              },
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
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
