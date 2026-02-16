import 'package:nachos_pet_care_flutter/models/pet.dart';

class AdoptionPet {
  final String id;
  final String name;
  final PetType type;
  final String? breed;
  final int? ageInMonths;
  final PetGender gender;
  final String? photoPath;
  final String description;
  final String location;
  final String contactPhone;
  final String contactEmail;
  final String shelterName;
  final bool isUrgent;
  final DateTime createdAt;

  AdoptionPet({
    required this.id,
    required this.name,
    required this.type,
    this.breed,
    this.ageInMonths,
    required this.gender,
    this.photoPath,
    required this.description,
    required this.location,
    required this.contactPhone,
    required this.contactEmail,
    required this.shelterName,
    this.isUrgent = false,
    required this.createdAt,
  });

  factory AdoptionPet.fromJson(Map<String, dynamic> json) {
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
      ageInMonths: json['ageInMonths'] as int?,
      gender: PetGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => PetGender.unknown,
      ),
      photoPath: getStringOrNull(json['photoPath']),
      description: json['description'] as String,
      location: json['location'] as String,
      contactPhone: json['contactPhone'] as String,
      contactEmail: json['contactEmail'] as String,
      shelterName: json['shelterName'] as String,
      isUrgent: json['isUrgent'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'breed': breed,
      'ageInMonths': ageInMonths,
      'gender': gender.name,
      'photoPath': (photoPath == null || photoPath!.isEmpty) ? null : photoPath,
      'description': description,
      'location': location,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'shelterName': shelterName,
      'isUrgent': isUrgent,
      'createdAt': createdAt.millisecondsSinceEpoch,
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
}
