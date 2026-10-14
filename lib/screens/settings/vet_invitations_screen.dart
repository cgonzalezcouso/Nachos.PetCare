import 'package:flutter/material.dart';
import 'package:nachos_pet_care_flutter/models/vet_invitation.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/services/vet_clinic_service.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/l10n/app_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VetInvitationsScreen extends StatefulWidget {
  const VetInvitationsScreen({super.key});

  @override
  State<VetInvitationsScreen> createState() => _VetInvitationsScreenState();
}

class _VetInvitationsScreenState extends State<VetInvitationsScreen> {
  final VetClinicService _vetService = getIt<VetClinicService>();
  final DatabaseService _dbService = getIt<DatabaseService>();
  
  List<Pet> _userPets = [];

  @override
  void initState() {
    super.initState();
    _loadUserPets();
  }

  Future<void> _loadUserPets() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? 'current_user_id';
      final pets = await _dbService.getPetsByOwner(currentUserId);
      setState(() {
        _userPets = pets;
      });
    } catch (_) {
      // Fallback a mascotas de demostración en modo sin conexión para asegurar pruebas
      setState(() {
        _userPets = [
          Pet(id: 'pet_nachito', ownerId: 'current_user_id', name: 'Nachito', type: PetType.dog, breed: 'Golden Retriever', gender: PetGender.male, createdAt: DateTime.now()),
          Pet(id: 'pet_kira', ownerId: 'current_user_id', name: 'Kira', type: PetType.cat, breed: 'Siamés', gender: PetGender.female, createdAt: DateTime.now()),
          Pet(id: 'pet_copito', ownerId: 'current_user_id', name: 'Copito', type: PetType.dog, breed: 'Bichón Maltés', gender: PetGender.male, createdAt: DateTime.now()),
        ];
      });
    }
  }

  void _showNewInvitationBottomSheet() {
    if (_userPets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registra primero una mascota para poder compartir su historial.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewInvitationForm(
        pets: _userPets,
        onSubmit: (pet, email, clinic) async {
          final userName = Supabase.instance.client.auth.currentUser?.email?.split('@').first ?? 'Dueño Nachos';
          await _vetService.sendInvitation(
            petId: pet.id,
            petName: pet.name,
            petPhoto: pet.photoPath,
            ownerName: userName.toUpperCase(),
            vetEmail: email,
            clinicName: clinic,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invitación enviada con éxito a $email 🐾'),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          strings.vetInvitations,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewInvitationBottomSheet,
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Invitar Veterinario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<VetInvitation>>(
        stream: _vetService.invitationsStream,
        initialData: const [],
        builder: (context, snapshot) {
          final list = snapshot.data ?? [];
          
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.share_location_outlined, size: 64, color: colorScheme.primary),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sin accesos compartidos',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Invita a tu veterinario de confianza para que pueda ver el historial médico, vacunas y evolución de peso de tus mascotas.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: list.length,
            itemBuilder: (context, idx) {
              final inv = list[idx];
              return _InvitationCard(inv: inv, onRevoke: () => _vetService.revokeInvitation(inv.id));
            },
          );
        },
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final VetInvitation inv;
  final VoidCallback onRevoke;

  const _InvitationCard({required this.inv, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusColor = Colors.orange;
    String statusText = 'Pendiente';
    IconData statusIcon = Icons.hourglass_empty;

    if (inv.status == 'accepted') {
      statusColor = Colors.green;
      statusText = 'Activo';
      statusIcon = Icons.check_circle_outline;
    } else if (inv.status == 'declined') {
      statusColor = Colors.red;
      statusText = 'Declinado';
      statusIcon = Icons.highlight_off;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.05),
                    colorScheme.primary.withValues(alpha: 0.01),
                  ],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage: inv.petPhoto != null && inv.petPhoto!.startsWith('http')
                        ? NetworkImage(inv.petPhoto!)
                        : null,
                    child: inv.petPhoto == null
                        ? Icon(Icons.pets, color: colorScheme.primary, size: 24)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inv.petName,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Clínica: ${inv.clinicName}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Veterinario Invitado:',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                        ),
                        Text(
                          inv.vetEmail,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Revocar Acceso'),
                          content: Text('¿Estás seguro de que deseas revocar el acceso del veterinario a los datos médicos de ${inv.petName}? Ya no podrá ver su historial.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onRevoke();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Revocar'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.link_off, size: 16, color: Colors.red),
                    label: const Text('Revocar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewInvitationForm extends StatefulWidget {
  final List<Pet> pets;
  final Function(Pet pet, String email, String clinic) onSubmit;

  const _NewInvitationForm({required this.pets, required this.onSubmit});

  @override
  State<_NewInvitationForm> createState() => _NewInvitationFormState();
}

class _NewInvitationFormState extends State<_NewInvitationForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _clinicController = TextEditingController();
  
  late Pet _selectedPet;

  @override
  void initState() {
    super.initState();
    _selectedPet = widget.pets.first;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _clinicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Invitar a un Veterinario',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Completa los datos de la clínica para otorgarle acceso de lectura seguro a los historiales médicos.',
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 24),
              
              // 🐾 Selección de Mascota
              Text(
                'Selecciona una mascota:',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Pet>(
                value: _selectedPet,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: widget.pets.map((pet) {
                  return DropdownMenuItem<Pet>(
                    value: pet,
                    child: Text(pet.name),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedPet = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // 📧 Email del Veterinario
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico del Veterinario',
                  hintText: 'ejemplo@clinica.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Por favor introduce un correo';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                    return 'Introduce un correo electrónico válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 🏥 Nombre de la Clínica
              TextFormField(
                controller: _clinicController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Clínica Veterinaria',
                  hintText: 'Clínica Veterinaria Nachos',
                  prefixIcon: const Icon(Icons.local_hospital_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Por favor introduce la clínica';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 🚀 Botón de Envío
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSubmit(
                      _selectedPet,
                      _emailController.text.trim(),
                      _clinicController.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Enviar Invitación 🐾', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
