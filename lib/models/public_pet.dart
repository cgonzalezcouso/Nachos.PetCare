import 'package:nachos_pet_care_flutter/models/pet.dart';

class PublicPet {
  final String id;
  final String ownerId;
  final String ownerName;
  final String name;
  final PetType type;
  final String? breed;
  final DateTime? birthDate;
  final PetGender gender;
  final String? photoPath;
  final String? notes;
  final bool isGalleryPublic;
  final int followersCount;
  final DateTime createdAt;

  PublicPet({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.name,
    required this.type,
    this.breed,
    this.birthDate,
    this.gender = PetGender.unknown,
    this.photoPath,
    this.notes,
    this.isGalleryPublic = false,
    this.followersCount = 0,
    required this.createdAt,
  });

  factory PublicPet.fromJson(Map<String, dynamic> json) {
    String? getStringOrNull(dynamic value) {
      if (value == null || value == '') return null;
      return value as String;
    }

    final typeStr = json['type'] as String? ?? 'other';
    final genderStr = json['gender'] as String? ?? 'unknown';

    return PublicPet(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String? ?? json['ownerId'] as String? ?? '',
      ownerName: json['owner_name'] as String? ?? json['ownerName'] as String? ?? 'Amigo de Nachos',
      name: json['name'] as String? ?? '',
      type: PetType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => PetType.other,
      ),
      breed: getStringOrNull(json['breed']),
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : json['birthDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['birthDate'] as int)
              : null,
      gender: PetGender.values.firstWhere(
        (e) => e.name == genderStr,
        orElse: () => PetGender.unknown,
      ),
      photoPath: getStringOrNull(json['photo_path'] ?? json['photoPath']),
      notes: getStringOrNull(json['notes']),
      isGalleryPublic: json['is_gallery_public'] == true || json['is_gallery_public'] == 1 || json['isGalleryPublic'] == true,
      followersCount: json['followers_count'] as int? ?? json['followersCount'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'name': name,
      'type': type.name,
      'breed': breed ?? '',
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender.name,
      'photo_path': photoPath,
      'notes': notes ?? '',
      'is_gallery_public': isGalleryPublic,
      'followers_count': followersCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get typeDisplayName {
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

  int? get ageInYears {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    return years;
  }

  PublicPet copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? name,
    PetType? type,
    String? breed,
    DateTime? birthDate,
    PetGender? gender,
    String? photoPath,
    String? notes,
    bool? isGalleryPublic,
    int? followersCount,
    DateTime? createdAt,
  }) {
    return PublicPet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      isGalleryPublic: isGalleryPublic ?? this.isGalleryPublic,
      followersCount: followersCount ?? this.followersCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
