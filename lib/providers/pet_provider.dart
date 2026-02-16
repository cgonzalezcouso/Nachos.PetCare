import 'package:flutter/foundation.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';

class PetProvider extends ChangeNotifier {
  final DatabaseService _dbService = getIt<DatabaseService>();

  List<Pet> _pets = [];
  Pet? _selectedPet;
  bool _isLoading = false;
  String? _error;

  List<Pet> get pets => _pets;
  Pet? get selectedPet => _selectedPet;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPets(String ownerId) async {
    _setLoading(true);

    try {
      _pets = await _dbService.getPetsByOwner(ownerId);
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar mascotas: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addPet(Pet pet) async {
    _setLoading(true);

    try {
      await _dbService.insertPet(pet);
      _pets.add(pet);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al añadir mascota: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePet(Pet pet) async {
    _setLoading(true);

    try {
      await _dbService.updatePet(pet);

      final index = _pets.indexWhere((p) => p.id == pet.id);
      if (index != -1) {
        _pets[index] = pet;
      }

      if (_selectedPet?.id == pet.id) {
        _selectedPet = pet;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al actualizar mascota: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePet(String petId) async {
    _setLoading(true);

    try {
      await _dbService.deletePet(petId);
      _pets.removeWhere((p) => p.id == petId);

      if (_selectedPet?.id == petId) {
        _selectedPet = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al eliminar mascota: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void selectPet(Pet pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPet = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
