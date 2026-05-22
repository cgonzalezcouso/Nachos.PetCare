import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/models/public_pet.dart';
import 'package:nachos_pet_care_flutter/models/public_pet_photo.dart';
import 'package:nachos_pet_care_flutter/models/public_comment.dart';
import 'package:nachos_pet_care_flutter/config/app_logger.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:uuid/uuid.dart';

class SocialService {
  final DatabaseService _db = getIt<DatabaseService>();

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // --- ALMACÉN EN MEMORIA PARA FALLBACK / MOCK (Windows / Offline / Sin tablas) ---
  bool _useMockFallback = false;
  final List<PublicPet> _mockPets = [];
  final List<PublicPetPhoto> _mockPhotos = [];
  final List<PublicComment> _mockComments = [];
  final List<Map<String, String>> _mockFollows = []; // List of { 'follower_user_id': '...', 'followed_pet_id': '...' }

  SocialService() {
    _initializeMockData();
  }

  void _initializeMockData() {
    AppLogger.info('SocialService: Inicializando base de datos mock en memoria...');

    // 1. Mascotas Mock
    final pet1 = PublicPet(
      id: 'mock-pet-nachito',
      ownerId: 'mock-owner-1',
      ownerName: 'Juan Pérez',
      name: 'Nachito',
      type: PetType.dog,
      breed: 'Labrador',
      birthDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      gender: PetGender.male,
      photoPath: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&q=80&w=300',
      notes: 'Muy cariñoso, le encanta correr y jugar en el parque.',
      isGalleryPublic: true,
      followersCount: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );

    final pet2 = PublicPet(
      id: 'mock-pet-kira',
      ownerId: 'mock-owner-2',
      ownerName: 'María Gómez',
      name: 'Kira',
      type: PetType.cat,
      breed: 'Siamés',
      birthDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      gender: PetGender.female,
      photoPath: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&q=80&w=300',
      notes: 'Una gatita tranquila pero muy juguetona por las noches.',
      isGalleryPublic: true,
      followersCount: 22,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    );

    final pet3 = PublicPet(
      id: 'mock-pet-copito',
      ownerId: 'mock-owner-3',
      ownerName: 'Carlos Ruiz',
      name: 'Copito',
      type: PetType.rabbit,
      breed: 'Angora',
      birthDate: DateTime.now().subtract(const Duration(days: 180)),
      gender: PetGender.unknown,
      photoPath: 'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?auto=format&fit=crop&q=80&w=300',
      notes: 'Le encanta comer zanahorias y lechuga fresca.',
      isGalleryPublic: true,
      followersCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    );

    _mockPets.addAll([pet1, pet2, pet3]);

    // 2. Fotos Mock
    final photo1 = PublicPetPhoto(
      id: 'mock-photo-1',
      petId: 'mock-pet-nachito',
      photoPath: 'https://images.unsplash.com/photo-1534361960057-19889db9621e?auto=format&fit=crop&q=80&w=300',
      date: DateTime.now().subtract(const Duration(days: 2)),
      notes: '¡Día de playa espectacular!',
    );

    final photo2 = PublicPetPhoto(
      id: 'mock-photo-2',
      petId: 'mock-pet-nachito',
      photoPath: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&q=80&w=300',
      date: DateTime.now().subtract(const Duration(days: 4)),
      notes: 'Esperando pacientemente su premio 🦴',
    );

    final photo3 = PublicPetPhoto(
      id: 'mock-photo-3',
      petId: 'mock-pet-kira',
      photoPath: 'https://images.unsplash.com/photo-1573865526739-10659fec78a5?auto=format&fit=crop&q=80&w=300',
      date: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Siesta al sol de la tarde ☀️',
    );

    final photo4 = PublicPetPhoto(
      id: 'mock-photo-4',
      petId: 'mock-pet-copito',
      photoPath: 'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?auto=format&fit=crop&q=80&w=300',
      date: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'Explorando la sala de estar.',
    );

    _mockPhotos.addAll([photo1, photo2, photo3, photo4]);

    // 3. Comentarios Mock
    _mockComments.addAll([
      PublicComment(
        id: 'mock-comment-1',
        photoId: 'mock-photo-1',
        userId: 'some-user-a',
        userName: 'Elena Flores',
        commentText: '¡Qué lindo! Le encanta el agua 🌊',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      PublicComment(
        id: 'mock-comment-2',
        photoId: 'mock-photo-1',
        userId: 'some-user-b',
        userName: 'Marcos Soto',
        commentText: 'Preciosa foto, ¡se nota que se divirtió mucho!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PublicComment(
        id: 'mock-comment-3',
        photoId: 'mock-photo-3',
        userId: 'some-user-a',
        userName: 'Elena Flores',
        commentText: 'Los gatos saben exactamente cómo disfrutar la vida.',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
    ]);
  }

  // --- MÉTODOS DEL SERVICIO ---

  /// Publicar una mascota en la red social
  Future<PublicPet> publishPet(Pet pet, bool isGalleryPublic, String ownerName) async {
    final publicPet = PublicPet(
      id: pet.id,
      ownerId: pet.ownerId,
      ownerName: ownerName,
      name: pet.name,
      type: pet.type,
      breed: pet.breed,
      birthDate: pet.birthDate,
      gender: pet.gender,
      photoPath: pet.photoPath,
      notes: pet.notes,
      isGalleryPublic: isGalleryPublic,
      followersCount: 0,
      createdAt: DateTime.now(),
    );

    // Intentar Supabase
    if (!_useMockFallback && _supabase != null) {
      try {
        await _supabase!.from('public_pets').upsert(publicPet.toJson());
        
        // Si la galería es pública, publicar también sus fotos locales
        if (isGalleryPublic) {
          final localPhotos = await _db.getPetPhotos(pet.id);
          for (final photo in localPhotos) {
            final publicPhoto = PublicPetPhoto(
              id: photo.id,
              petId: pet.id,
              photoPath: photo.photoPath,
              date: photo.date,
              notes: photo.notes,
            );
            await _supabase!.from('public_pet_photos').upsert(publicPhoto.toJson());
          }
        } else {
          // Si no es pública, borrar sus fotos públicas si existían
          await _supabase!.from('public_pet_photos').delete().eq('pet_id', pet.id);
        }
        AppLogger.info('SocialService (Supabase): Mascota publicada con éxito: ${pet.name}');
        return publicPet;
      } catch (e) {
        AppLogger.warn('SocialService (Supabase): Falló publicación. Activando fallback local. Error: $e');
        _useMockFallback = true;
      }
    }

    // Fallback Mock
    _mockPets.removeWhere((p) => p.id == pet.id);
    _mockPets.add(publicPet);

    // Sincronizar fotos
    if (isGalleryPublic) {
      _mockPhotos.removeWhere((p) => p.petId == pet.id);
      final localPhotos = await _db.getPetPhotos(pet.id);
      for (final photo in localPhotos) {
        _mockPhotos.add(PublicPetPhoto(
          id: photo.id,
          petId: pet.id,
          photoPath: photo.photoPath,
          date: photo.date,
          notes: photo.notes,
        ));
      }
    } else {
      _mockPhotos.removeWhere((p) => p.petId == pet.id);
    }

    return publicPet;
  }

  /// Retirar una mascota de la red social
  Future<void> unpublishPet(String petId) async {
    if (!_useMockFallback && _supabase != null) {
      try {
        await _supabase!.from('public_pets').delete().eq('id', petId);
        await _supabase!.from('public_pet_photos').delete().eq('pet_id', petId);
        await _supabase!.from('public_pet_follows').delete().eq('followed_pet_id', petId);
        AppLogger.info('SocialService (Supabase): Mascota despublicada con éxito: $petId');
        return;
      } catch (e) {
        AppLogger.warn('SocialService (Supabase): Falló despublicación. Activando fallback local. Error: $e');
        _useMockFallback = true;
      }
    }

    _mockPets.removeWhere((p) => p.id == petId);
    _mockPhotos.removeWhere((p) => p.petId == petId);
    _mockFollows.removeWhere((f) => f['followed_pet_id'] == petId);
  }

  /// Buscar mascotas públicas
  Future<List<PublicPet>> getPublicPets({String? query}) async {
    if (!_useMockFallback && _supabase != null) {
      try {
        var queryBuilder = _supabase!.from('public_pets').select();
        if (query != null && query.isNotEmpty) {
          queryBuilder = queryBuilder.ilike('name', '%$query%');
        }
        final data = await queryBuilder.order('followers_count', ascending: false);
        return (data as List).map((json) => PublicPet.fromJson(json)).toList();
      } catch (e) {
        AppLogger.warn('SocialService (Supabase): Falló obtención de mascotas públicas. Usando fallback. Error: $e');
        _useMockFallback = true;
      }
    }

    // Fallback Mock
    if (query != null && query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      return _mockPets
          .where((p) => p.name.toLowerCase().contains(lowercaseQuery) || (p.breed?.toLowerCase().contains(lowercaseQuery) ?? false))
          .toList()
        ..sort((a, b) => b.followersCount.compareTo(a.followersCount));
    }
    return List.from(_mockPets)..sort((a, b) => b.followersCount.compareTo(a.followersCount));
  }

  /// Obtener una mascota pública por su ID
  Future<PublicPet?> getPublicPetById(String id) async {
    if (!_useMockFallback && _supabase != null) {
      try {
        final data = await _supabase!.from('public_pets').select().eq('id', id).maybeSingle();
        if (data != null) return PublicPet.fromJson(data);
      } catch (e) {
        AppLogger.warn('SocialService (Supabase): Falló obtención por ID. Usando fallback. Error: $e');
        _useMockFallback = true;
      }
    }

    final index = _mockPets.indexWhere((p) => p.id == id);
    if (index != -1) return _mockPets[index];
    return null;
  }

  /// Comprobar si una mascota está publicada
  Future<bool> isPetPublished(String petId) async {
    if (!_useMockFallback && _supabase != null) {
      try {
        final data = await _supabase!.from('public_pets').select('id').eq('id', petId).maybeSingle();
        return data != null;
      } catch (e) {
        _useMockFallback = true;
      }
    }

    return _mockPets.any((p) => p.id == petId);
  }

  /// Comprobar si seguimos a una mascota
  Future<bool> isFollowing(String userId, String petId) async {
    if (!_useMockFallback && _supabase != null) {
      try {
        final data = await _supabase!
            .from('public_pet_follows')
            .select()
            .eq('follower_user_id', userId)
            .eq('followed_pet_id', petId)
            .maybeSingle();
        return data != null;
      } catch (e) {
        _useMockFallback = true;
      }
    }

    return _mockFollows.any((f) => f['follower_user_id'] == userId && f['followed_pet_id'] == petId);
  }

  /// Seguir una mascota
  Future<void> followPet(String userId, String petId) async {
    if (!_useMockFallback && _supabase != null) {
      try {
        await _supabase!.from('public_pet_follows').upsert({
          'id': const Uuid().v4(),
          'follower_user_id': userId,
          'followed_pet_id': petId,
          'created_at': DateTime.now().toIso8601String(),
        });
        
        // Incrementar seguidores
        final pet = await getPublicPetById(petId);
        if (pet != null) {
          await _supabase!
              .from('public_pets')
              .update({'followers_count': pet.followersCount + 1})
              .eq('id', petId);
        }
        return;
      } catch (e) {
        _useMockFallback = true;
      }
    }

    // Mock Follow
    final alreadyFollowing = _mockFollows.any((f) => f['follower_user_id'] == userId && f['followed_pet_id'] == petId);
    if (!alreadyFollowing) {
      _mockFollows.add({'follower_user_id': userId, 'followed_pet_id': petId});
      
      // Incrementar en mock
      final index = _mockPets.indexWhere((p) => p.id == petId);
      if (index != -1) {
        final p = _mockPets[index];
        _mockPets[index] = p.copyWith(followersCount: p.followersCount + 1);
      }
    }
  }

  /// Dejar de seguir una mascota
  Future<void> unfollowPet(String userId, String petId) async {
    if (!_useMockFallback && _supabase != null) {
      try {
        await _supabase!
            .from('public_pet_follows')
            .delete()
            .eq('follower_user_id', userId)
            .eq('followed_pet_id', petId);
        
        // Decrementar seguidores
        final pet = await getPublicPetById(petId);
        if (pet != null && pet.followersCount > 0) {
          await _supabase!
              .from('public_pets')
              .update({'followers_count': pet.followersCount - 1})
              .eq('id', petId);
        }
        return;
      } catch (e) {
        _useMockFallback = true;
      }
    }

    // Mock Unfollow
    _mockFollows.removeWhere((f) => f['follower_user_id'] == userId && f['followed_pet_id'] == petId);
    
    // Decrementar en mock
    final index = _mockPets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      final p = _mockPets[index];
      if (p.followersCount > 0) {
        _mockPets[index] = p.copyWith(followersCount: p.followersCount - 1);
      }
    }
  }

  /// Obtener fotos de la galería de una mascota pública
  Future<List<PublicPetPhoto>> getPetPhotos(String petId) async {
    if (!_useMockFallback && _supabase != null) {
      try {
        final data = await _supabase!
            .from('public_pet_photos')
            .select()
            .eq('pet_id', petId)
            .order('date', ascending: false);
        return (data as List).map((json) => PublicPetPhoto.fromJson(json)).toList();
      } catch (e) {
        _useMockFallback = true;
      }
    }

    return _mockPhotos.where((p) => p.petId == petId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Obtener feed de fotos de las mascotas seguidas
  Future<List<Map<String, dynamic>>> getFollowedFeed(String userId) async {
    final List<Map<String, dynamic>> feed = [];

    if (!_useMockFallback && _supabase != null) {
      try {
        // 1. Obtener IDs de mascotas seguidas
        final followsData = await _supabase!
            .from('public_pet_follows')
            .select('followed_pet_id')
            .eq('follower_user_id', userId);
        
        final followedIds = (followsData as List).map((f) => f['followed_pet_id'] as String).toList();
        if (followedIds.isEmpty) return [];

        // 2. Obtener fotos de esas mascotas
        final photosData = await _supabase!
            .from('public_pet_photos')
            .select()
            .inFilter('pet_id', followedIds)
            .order('date', ascending: false);
        
        final photos = (photosData as List).map((json) => PublicPetPhoto.fromJson(json)).toList();

        // 3. Emparejar con info de la mascota
        for (final photo in photos) {
          final pet = await getPublicPetById(photo.petId);
          if (pet != null) {
            feed.add({
              'photo': photo,
              'pet': pet,
            });
          }
        }
        return feed;
      } catch (e) {
        _useMockFallback = true;
      }
    }

    // Mock Feed
    final followedIds = _mockFollows
        .where((f) => f['follower_user_id'] == userId)
        .map((f) => f['followed_pet_id']!)
        .toList();

    if (followedIds.isEmpty) return [];

    final photos = _mockPhotos.where((p) => followedIds.contains(p.petId)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final photo in photos) {
      final pet = _mockPets.firstWhere((p) => p.id == photo.petId);
      feed.add({
        'photo': photo,
        'pet': pet,
      });
    }

    return feed;
  }

  /// Obtener comentarios de una foto
  Future<List<PublicComment>> getComments(String photoId) async {
    if (!_useMockFallback && _supabase != null) {
      try {
        final data = await _supabase!
            .from('public_photo_comments')
            .select()
            .eq('photo_id', photoId)
            .order('created_at', ascending: true);
        return (data as List).map((json) => PublicComment.fromJson(json)).toList();
      } catch (e) {
        _useMockFallback = true;
      }
    }

    return _mockComments.where((c) => c.photoId == photoId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Añadir un comentario a una foto
  Future<PublicComment> addComment(String photoId, String userId, String userName, String commentText) async {
    final comment = PublicComment(
      id: const Uuid().v4(),
      photoId: photoId,
      userId: userId,
      userName: userName,
      commentText: commentText,
      createdAt: DateTime.now(),
    );

    if (!_useMockFallback && _supabase != null) {
      try {
        await _supabase!.from('public_photo_comments').insert(comment.toJson());
        return comment;
      } catch (e) {
        _useMockFallback = true;
      }
    }

    _mockComments.add(comment);
    return comment;
  }
}
