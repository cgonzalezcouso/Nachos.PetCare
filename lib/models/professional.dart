enum ProfessionalType {
  trainer,       // Adiestrador
  nutritionist,  // Nutricionista
  ethologist,    // Etólogo
  groomer,       // Peluquero
  veterinarian,  // Veterinario
  petFriendly    // Sitio pet friendly (restaurantes, hoteles, etc.)
}

class Professional {
  final String id;
  final String name;
  final ProfessionalType type;
  final String? businessName;
  final String description;
  final String address;
  final String? city;
  final String phone;
  final String? email;
  final String? website;
  final double? rating;
  final String? photoUrl;
  final List<String> specialties;
  final bool isVerified;

  Professional({
    required this.id,
    required this.name,
    required this.type,
    this.businessName,
    required this.description,
    required this.address,
    this.city,
    required this.phone,
    this.email,
    this.website,
    this.rating,
    this.photoUrl,
    this.specialties = const [],
    this.isVerified = false,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    String? getStringOrNull(dynamic value) {
      if (value == null || value == '') return null;
      return value as String;
    }

    return Professional(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ProfessionalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProfessionalType.veterinarian,
      ),
      businessName: getStringOrNull(json['businessName']),
      description: json['description'] as String,
      address: json['address'] as String,
      city: getStringOrNull(json['city']),
      phone: json['phone'] as String,
      email: getStringOrNull(json['email']),
      website: getStringOrNull(json['website']),
      rating: (json['rating'] as num?)?.toDouble(),
      photoUrl: getStringOrNull(json['photoUrl']),
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'businessName': businessName,
      'description': description,
      'address': address,
      'city': city,
      'phone': phone,
      'email': email,
      'website': website,
      'rating': rating,
      'photoUrl': (photoUrl == null || photoUrl!.isEmpty) ? null : photoUrl,
      'specialties': specialties,
      'isVerified': isVerified,
    };
  }

  String get typeDisplayName {
    switch (type) {
      case ProfessionalType.trainer:
        return 'Adiestrador';
      case ProfessionalType.nutritionist:
        return 'Nutricionista';
      case ProfessionalType.ethologist:
        return 'Etólogo';
      case ProfessionalType.groomer:
        return 'Peluquero';
      case ProfessionalType.veterinarian:
        return 'Veterinario';
      case ProfessionalType.petFriendly:
        return 'Pet Friendly';
    }
  }
}
