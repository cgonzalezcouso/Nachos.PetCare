enum PetType {
  dog,           // Perro
  cat,           // Gato
  rabbit,        // Conejo
  rodent,        // Roedor (hámster, cobaya, rata, ratón, jerbo, chinchilla)
  ferret,        // Hurón
  bird,          // Ave (periquito, canario, ninfa, agapornis, loro)
  fish,          // Pez (agua dulce / marino)
  reptile,       // Reptil (tortuga, gecko, dragón barbudo, serpiente)
  amphibian,     // Anfibio (axolote, rana, tritón)
  invertebrate,  // Invertebrado (tarántula, mantis, insecto palo, caracol)
  farmAnimal,    // Animal de corral (gallina, pato, cabra/oveja, cerdo)
  other          // Otro / Exótico
}

enum PetGender { male, female, unknown }

class Pet {
  final String id;
  final String ownerId;
  final String name;
  final PetType type;
  final String? breed;
  final DateTime? birthDate;
  final PetGender gender;
  final double? weight;
  final String? photoPath;
  final String? notes;
  final String? microchipNumber;
  final bool isNeutered;
  final DateTime createdAt;

  Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    this.breed,
    this.birthDate,
    this.gender = PetGender.unknown,
    this.weight,
    this.photoPath,
    this.notes,
    this.microchipNumber,
    this.isNeutered = false,
    required this.createdAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    // Convertir cadenas vacías en null
    String? getStringOrNull(dynamic value) {
      if (value == null || value == '') return null;
      return value as String;
    }
    
    // Compatibilidad con tipos antiguos
    String typeStr = json['type'] as String;
    if (typeStr == 'hamster') {
      typeStr = 'rodent';
    }
    
    return Pet(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      type: PetType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => PetType.other,
      ),
      breed: getStringOrNull(json['breed']),
      birthDate: json['birthDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['birthDate'] as int)
          : null,
      gender: PetGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => PetGender.unknown,
      ),
      weight: (json['weight'] as num?)?.toDouble(),
      photoPath: getStringOrNull(json['photoPath']),
      notes: getStringOrNull(json['notes']),
      microchipNumber: getStringOrNull(json['microchipNumber']),
      isNeutered: (json['isNeutered'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'type': type.name,
      'breed': breed ?? '',
      'birthDate': birthDate?.millisecondsSinceEpoch,
      'gender': gender.name,
      'weight': weight,
      'photoPath': (photoPath == null || photoPath!.isEmpty) ? null : photoPath,
      'notes': notes ?? '',
      'microchipNumber': microchipNumber ?? '',
      'isNeutered': isNeutered ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
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

  String get typeDisplayName {
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

  Pet copyWith({
    String? id,
    String? ownerId,
    String? name,
    PetType? type,
    String? breed,
    DateTime? birthDate,
    PetGender? gender,
    double? weight,
    String? photoPath,
    String? notes,
    String? microchipNumber,
    bool? isNeutered,
    DateTime? createdAt,
  }) {
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      isNeutered: isNeutered ?? this.isNeutered,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
