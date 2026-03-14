import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';

class EditPetScreen extends StatefulWidget {
  final String petId;

  const EditPetScreen({super.key, required this.petId});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  PetType _selectedType = PetType.dog;
  PetGender _selectedGender = PetGender.unknown;
  DateTime? _birthDate;
  bool _isLoading = false;
  Pet? _originalPet;

  // Foto
  File? _pickedImageFile;       // foto nueva seleccionada del dispositivo
  String? _currentPhotoPath;    // foto existente guardada en el pet

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  void _loadPet() {
    final petProvider = context.read<PetProvider>();
    final pet = petProvider.pets.firstWhere(
      (p) => p.id == widget.petId,
      orElse: () => Pet(
        id: '',
        ownerId: '',
        name: '',
        type: PetType.dog,
        createdAt: DateTime.now(),
      ),
    );

    if (pet.id.isEmpty) return;

    _originalPet = pet;
    _nameController.text = pet.name;
    _breedController.text = pet.breed ?? '';
    _weightController.text = pet.weight != null ? pet.weight.toString() : '';
    _notesController.text = pet.notes ?? '';
    setState(() {
      _selectedType = pet.type;
      _selectedGender = pet.gender;
      _birthDate = pet.birthDate;
      _currentPhotoPath = pet.photoPath;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            if (_currentPhotoPath != null || _pickedImageFile != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(ctx, null),
              ),
          ],
        ),
      ),
    );

    // null = eliminar foto (returned via tap on ListTile)
    if (!mounted) return;

    if (source == null && (_currentPhotoPath != null || _pickedImageFile != null)) {
      setState(() {
        _pickedImageFile = null;
        _currentPhotoPath = null;
      });
      return;
    }

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          _pickedImageFile = File(picked.path);
          _currentPhotoPath = picked.path; // guardar ruta local
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo acceder a la cámara/galería: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _birthDate = date);
    }
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_originalPet == null) return;

    setState(() => _isLoading = true);

    try {
      final petProvider = context.read<PetProvider>();

      final updatedPet = _originalPet!.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
        birthDate: _birthDate,
        gender: _selectedGender,
        weight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        photoPath: _currentPhotoPath,
      );

      final success = await petProvider.updatePet(updatedPet);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mascota actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Navegar explícitamente de vuelta al detalle (context.go reemplazó el stack)
        context.go('/pets/${widget.petId}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(petProvider.error ?? 'Error al actualizar la mascota.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_originalPet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar mascota')),
        body: const Center(child: Text('Mascota no encontrada')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar · ${_originalPet!.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets/${widget.petId}'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Foto ──────────────────────────────────────────────
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage: _pickedImageFile != null
                            ? FileImage(_pickedImageFile!)
                            : (_currentPhotoPath != null && _currentPhotoPath!.isNotEmpty
                                ? (Uri.tryParse(_currentPhotoPath!)?.hasScheme == true && _currentPhotoPath!.startsWith('http')
                                    ? NetworkImage(_currentPhotoPath!) as ImageProvider
                                    : FileImage(File(_currentPhotoPath!)))
                                : null),
                        child: (_pickedImageFile == null &&
                                (_currentPhotoPath == null || _currentPhotoPath!.isEmpty))
                            ? Icon(
                                Icons.pets,
                                size: 48,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Toca para cambiar la foto',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 24),

              // ── Nombre ───────────────────────────────────────────
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre de tu mascota';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Tipo ─────────────────────────────────────────────
              DropdownButtonFormField<PetType>(
                initialValue: _selectedType,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Tipo de mascota *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: PetType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeName(type), overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),

              // ── Raza ─────────────────────────────────────────────
              TextFormField(
                controller: _breedController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: _getBreedLabel(),
                  prefixIcon: const Icon(Icons.pets),
                ),
              ),
              const SizedBox(height: 16),

              // ── Género ───────────────────────────────────────────
              DropdownButtonFormField<PetGender>(
                initialValue: _selectedGender,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Género',
                  prefixIcon: Icon(Icons.wc),
                ),
                items: const [
                  DropdownMenuItem(value: PetGender.male, child: Text('Macho')),
                  DropdownMenuItem(value: PetGender.female, child: Text('Hembra')),
                  DropdownMenuItem(value: PetGender.unknown, child: Text('Desconocido')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedGender = value);
                },
              ),
              const SizedBox(height: 16),

              // ── Fecha de nacimiento ───────────────────────────────
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cake),
                title: Text(
                  _birthDate != null
                      ? 'Fecha de nacimiento: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                      : 'Seleccionar fecha de nacimiento',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_birthDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _birthDate = null),
                        tooltip: 'Quitar fecha',
                      ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
                onTap: _selectBirthDate,
              ),
              const SizedBox(height: 16),

              // ── Peso ─────────────────────────────────────────────
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
              ),
              const SizedBox(height: 16),

              // ── Notas ────────────────────────────────────────────
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // ── Botón guardar ─────────────────────────────────────
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _savePet,
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeName(PetType type) {
    switch (type) {
      case PetType.dog: return 'Perro';
      case PetType.cat: return 'Gato';
      case PetType.rabbit: return 'Conejo';
      case PetType.rodent: return 'Roedor';
      case PetType.ferret: return 'Hurón';
      case PetType.bird: return 'Ave';
      case PetType.fish: return 'Pez';
      case PetType.reptile: return 'Reptil';
      case PetType.amphibian: return 'Anfibio';
      case PetType.invertebrate: return 'Invertebrado';
      case PetType.farmAnimal: return 'Animal de corral';
      case PetType.other: return 'Otro / Exótico';
    }
  }

  String _getBreedLabel() {
    switch (_selectedType) {
      case PetType.rodent: return 'Subtipo (ej: Hámster, Cobaya, Rata)';
      case PetType.bird: return 'Subtipo (ej: Periquito, Canario, Loro)';
      case PetType.fish: return 'Subtipo (ej: Agua dulce, Marino)';
      case PetType.reptile: return 'Subtipo (ej: Tortuga, Gecko, Serpiente)';
      case PetType.amphibian: return 'Subtipo (ej: Axolote, Rana, Tritón)';
      case PetType.invertebrate: return 'Subtipo (ej: Tarántula, Mantis, Caracol)';
      case PetType.farmAnimal: return 'Subtipo (ej: Gallina, Pato, Cabra)';
      case PetType.other: return 'Especie o tipo';
      default: return 'Raza (opcional)';
    }
  }
}
