import 'package:nachos_pet_care_flutter/models/pet.dart';

/// Tamaño del animal en adopción
enum PetSize { small, medium, large }

class AdoptionPet {
  final String id;
  final String name;
  final PetType type;
  final String? breed;
  final int? ageInMonths;
  final PetGender gender;
  final String? photoUrl;
  final String description;
  final String location;
  final String contactPhone;
  final String contactEmail;
  final String shelterName;
  final bool isUrgent;
  final bool vaccinated;
  final bool sterilized;
  final PetSize size;
  final String status; // 'available', 'adopted', 'reserved'
  final DateTime createdAt;

  AdoptionPet({
    required this.id,
    required this.name,
    required this.type,
    this.breed,
    this.ageInMonths,
    required this.gender,
    this.photoUrl,
    required this.description,
    required this.location,
    required this.contactPhone,
    required this.contactEmail,
    required this.shelterName,
    this.isUrgent = false,
    this.vaccinated = false,
    this.sterilized = false,
    this.size = PetSize.medium,
    this.status = 'available',
    required this.createdAt,
  });

  /// Desde JSON de Supabase (snake_case)
  factory AdoptionPet.fromSupabase(Map<String, dynamic> json) {
    String? getStringOrNull(dynamic value) {
      if (value == null || value == '') return null;
      return value as String;
    }

    return AdoptionPet(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PetType.other,
      ),
      breed: getStringOrNull(json['breed']),
      ageInMonths: json['age_in_months'] as int?,
      gender: PetGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => PetGender.unknown,
      ),
      photoUrl: getStringOrNull(json['photo_url']),
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      contactEmail: json['contact_email'] as String? ?? '',
      shelterName: json['shelter_name'] as String? ?? '',
      isUrgent: json['is_urgent'] as bool? ?? false,
      vaccinated: json['vaccinated'] as bool? ?? false,
      sterilized: json['sterilized'] as bool? ?? false,
      size: PetSize.values.firstWhere(
        (e) => e.name == (json['size'] ?? 'medium'),
        orElse: () => PetSize.medium,
      ),
      status: json['status'] as String? ?? 'available',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Para insertar/actualizar en Supabase (sin el id si es nuevo)
  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'type': type.name,
      'breed': breed,
      'age_in_months': ageInMonths,
      'gender': gender.name,
      'photo_url': (photoUrl == null || photoUrl!.isEmpty) ? null : photoUrl,
      'description': description,
      'location': location,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'shelter_name': shelterName,
      'is_urgent': isUrgent,
      'vaccinated': vaccinated,
      'sterilized': sterilized,
      'size': size.name,
      'status': status,
    };
  }

  String get ageDisplay {
    if (ageInMonths == null) return 'Edad desconocida';
    if (ageInMonths! < 12) return '$ageInMonths meses';
    final years = (ageInMonths! / 12).floor();
    final months = ageInMonths! % 12;
    if (months == 0) return '$years ${years == 1 ? 'año' : 'años'}';
    return '$years ${years == 1 ? 'año' : 'años'} y $months meses';
  }

  String get sizeDisplay {
    switch (size) {
      case PetSize.small:
        return 'Pequeño';
      case PetSize.medium:
        return 'Mediano';
      case PetSize.large:
        return 'Grande';
    }
  }
}
