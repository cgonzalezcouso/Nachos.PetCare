import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nachos_pet_care_flutter/models/adoption_pet.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';

class AdoptionService {
  static const String _table = 'adoption_pets';

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene todos los animales disponibles, con filtros opcionales.
  Future<List<AdoptionPet>> getAdoptionPets({
    PetType? type,
    String status = 'available',
  }) async {
    if (_supabase == null) {
      debugPrint('⚠️ AdoptionService: Supabase no inicializado');
      return [];
    }
    try {
      // Aplicar filtros antes de order() para mantener tipos correctos en v2
      var filterBuilder = _supabase!
          .from(_table)
          .select()
          .eq('status', status);

      if (type != null) {
        filterBuilder = filterBuilder.eq('type', type.name);
      }

      final data = await filterBuilder
          .order('is_urgent', ascending: false)
          .order('created_at', ascending: false);

      return (data as List)
          .map((json) => AdoptionPet.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('❌ AdoptionService.getAdoptionPets: $e\n$st');
      rethrow;
    }
  }

  /// Obtiene un animal por su ID.
  Future<AdoptionPet?> getAdoptionPetById(String id) async {
    if (_supabase == null) return null;
    try {
      final data = await _supabase!
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (data == null) return null;
      return AdoptionPet.fromSupabase(data);
    } catch (e, st) {
      debugPrint('❌ AdoptionService.getAdoptionPetById: $e\n$st');
      rethrow;
    }
  }

  /// Inserta un nuevo animal en adopción. Devuelve el objeto con el ID asignado.
  Future<AdoptionPet> insertAdoptionPet(AdoptionPet pet) async {
    if (_supabase == null) throw Exception('Supabase no está configurado');
    try {
      final data = await _supabase!
          .from(_table)
          .insert(pet.toSupabase())
          .select()
          .single();
      return AdoptionPet.fromSupabase(data);
    } catch (e, st) {
      debugPrint('❌ AdoptionService.insertAdoptionPet: $e\n$st');
      rethrow;
    }
  }

  /// Actualiza un animal existente.
  Future<AdoptionPet> updateAdoptionPet(AdoptionPet pet) async {
    if (_supabase == null) throw Exception('Supabase no está configurado');
    try {
      final data = await _supabase!
          .from(_table)
          .update(pet.toSupabase())
          .eq('id', pet.id)
          .select()
          .single();
      return AdoptionPet.fromSupabase(data);
    } catch (e, st) {
      debugPrint('❌ AdoptionService.updateAdoptionPet: $e\n$st');
      rethrow;
    }
  }

  /// Elimina un animal por su ID.
  Future<void> deleteAdoptionPet(String id) async {
    if (_supabase == null) throw Exception('Supabase no está configurado');
    try {
      await _supabase!.from(_table).delete().eq('id', id);
    } catch (e, st) {
      debugPrint('❌ AdoptionService.deleteAdoptionPet: $e\n$st');
      rethrow;
    }
  }
}
