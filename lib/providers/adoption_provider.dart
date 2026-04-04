import 'package:flutter/foundation.dart';
import 'package:nachos_pet_care_flutter/models/adoption_pet.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/services/adoption_service.dart';

class AdoptionProvider extends ChangeNotifier {
  final AdoptionService _service;

  AdoptionProvider({AdoptionService? service})
      : _service = service ?? AdoptionService();

  List<AdoptionPet> _pets = [];
  bool _isLoading = false;
  String? _error;
  PetType? _selectedType;

  List<AdoptionPet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PetType? get selectedType => _selectedType;
  AdoptionService get service => _service;

  List<AdoptionPet> get filteredPets {
    if (_selectedType == null) return _pets;
    return _pets.where((p) => p.type == _selectedType).toList();
  }

  /// Carga los animales desde Supabase.
  Future<void> loadAdoptionPets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pets = await _service.getAdoptionPets();
    } catch (e) {
      _error = 'No se pudieron cargar los animales en adopción.\n$e';
      debugPrint('❌ AdoptionProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filtra por tipo de animal (null = todos).
  void filterByType(PetType? type) {
    _selectedType = type;
    notifyListeners();
  }

  /// Elimina un animal y recarga la lista.
  Future<void> deleteAdoptionPet(String id) async {
    try {
      await _service.deleteAdoptionPet(id);
      _pets.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar: $e';
      notifyListeners();
    }
  }
}
