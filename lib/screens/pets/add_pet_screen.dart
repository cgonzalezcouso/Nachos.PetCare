import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/providers/auth_provider.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';
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

  PetType _selectedType = PetType.dog;
  PetGender _selectedGender = PetGender.unknown;
  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
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

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final petProvider = context.read<PetProvider>();

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
      createdAt: DateTime.now(),
    );

    final success = await petProvider.addPet(pet);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      context.pop();
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
