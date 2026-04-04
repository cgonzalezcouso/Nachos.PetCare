import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/providers/auth_provider.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';
import 'package:nachos_pet_care_flutter/utils/image_picker_helper.dart';
import 'package:uuid/uuid.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  final _microchipController = TextEditingController();

  PetType _selectedType = PetType.dog;
  PetGender _selectedGender = PetGender.unknown;
  DateTime? _birthDate;
  bool _isLoading = false;
  bool _isNeutered = false;
  File? _pickedImageFile;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    _microchipController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final bool desktop = ImagePickerHelper.isDesktop;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!desktop) ...[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('Seleccionar archivo de imagen'),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
            if (_pickedImageFile != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto',
                    style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(ctx, 'delete'),
              ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    if (action == 'delete') {
      setState(() => _pickedImageFile = null);
      return;
    }

    try {
      final path = action == 'camera'
          ? await ImagePickerHelper.pickFromCamera()
          : await ImagePickerHelper.pickFromGallery();
      if (path != null && mounted) {
        setState(() => _pickedImageFile = File(path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo acceder a la imagen: $e'),
            backgroundColor: Colors.red,
          ),
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
      setState(() {
        _birthDate = date;
      });
    }
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final petProvider = context.read<PetProvider>();

    // Verificar que hay usuario autenticado
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: no hay sesión activa. Por favor, inicia sesión de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final pet = Pet(
        id: const Uuid().v4(),
        ownerId: authProvider.user!.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
        birthDate: _birthDate,
        gender: _selectedGender,
        weight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        photoPath: _pickedImageFile?.path,
        microchipNumber: _microchipController.text.trim().isEmpty
            ? null
            : _microchipController.text.trim(),
        isNeutered: _isNeutered,
        createdAt: DateTime.now(),
      );

      final success = await petProvider.addPet(pet);

      if (!mounted) return;

      if (success) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(petProvider.error ?? 'Error al guardar la mascota. Inténtalo de nuevo.'),
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir mascota'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Foto ────────────────────────────────────────────────
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage: _pickedImageFile != null
                            ? FileImage(_pickedImageFile!)
                            : null,
                        child: _pickedImageFile == null
                            ? Icon(
                                Icons.pets,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Toca para añadir foto',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 24),

              // Name
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

              // Type dropdown
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
                    child: Text(
                      _getTypeName(type),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Breed / Subtype
              TextFormField(
                controller: _breedController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: _getBreedLabel(),
                  prefixIcon: const Icon(Icons.pets),
                ),
              ),
              const SizedBox(height: 16),

              // Gender dropdown
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
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Birth date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cake),
                title: Text(
                  _birthDate != null
                      ? 'Fecha de nacimiento: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                      : 'Seleccionar fecha de nacimiento',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectBirthDate,
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
              ),
              const SizedBox(height: 16),

              // Microchip
              TextFormField(
                controller: _microchipController,
                keyboardType: TextInputType.number,
                maxLength: 15,
                decoration: const InputDecoration(
                  labelText: 'Número de microchip (opcional)',
                  prefixIcon: Icon(Icons.memory),
                  helperText: 'Número de 15 dígitos del chip de identificación',
                  counterText: '',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final digits = value.replaceAll(RegExp(r'\D'), '');
                    if (digits.length != 15) {
                      return 'El microchip debe tener exactamente 15 dígitos';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Esterilizado/a
              Card(
                margin: EdgeInsets.zero,
                child: SwitchListTile(
                  value: _isNeutered,
                  onChanged: (val) => setState(() => _isNeutered = val),
                  title: const Text('Esterilizado/a'),
                  subtitle: Text(
                    _isNeutered
                        ? 'Sí, está esterilizado/a'
                        : 'No está esterilizado/a',
                  ),
                  secondary: Icon(
                    Icons.medical_services_outlined,
                    color: _isNeutered
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
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

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _savePet,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar mascota'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeName(PetType type) {
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
        return 'Otro / Exótico';
    }
  }
  
  String _getBreedLabel() {
    switch (_selectedType) {
      case PetType.rodent:
        return 'Subtipo (ej: Hámster, Cobaya, Rata)';
      case PetType.bird:
        return 'Subtipo (ej: Periquito, Canario, Loro)';
      case PetType.fish:
        return 'Subtipo (ej: Agua dulce, Marino)';
      case PetType.reptile:
        return 'Subtipo (ej: Tortuga, Gecko, Serpiente)';
      case PetType.amphibian:
        return 'Subtipo (ej: Axolote, Rana, Tritón)';
      case PetType.invertebrate:
        return 'Subtipo (ej: Tarántula, Mantis, Caracol)';
      case PetType.farmAnimal:
        return 'Subtipo (ej: Gallina, Pato, Cabra)';
      case PetType.other:
        return 'Especie o tipo';
      default:
        return 'Raza (opcional)';
    }
  }
}
