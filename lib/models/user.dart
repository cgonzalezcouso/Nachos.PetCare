class User {
  final String id;
  final String email;
  final String name;
  final String surname;
  final String? profilePhotoPath;
  final String? address;
  final String? postalCode;
  final String? city;
  final String? phone;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    this.profilePhotoPath,
    this.address,
    this.postalCode,
    this.city,
    this.phone,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Convertir cadenas vacías en null
    String? getStringOrNull(dynamic value) {
      if (value == null || value == '') return null;
      return value as String;
    }
    
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      profilePhotoPath: getStringOrNull(json['profilePhotoPath']),
      address: getStringOrNull(json['address']),
      postalCode: getStringOrNull(json['postalCode']),
      city: getStringOrNull(json['city']),
      phone: getStringOrNull(json['phone']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'surname': surname,
      'profilePhotoPath': (profilePhotoPath == null || profilePhotoPath!.isEmpty) 
          ? null 
          : profilePhotoPath,
      'address': address ?? '',
      'postalCode': postalCode ?? '',
      'city': city ?? '',
      'phone': phone ?? '',
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  String get fullName => '$name $surname';

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? surname,
    String? profilePhotoPath,
    String? address,
    String? postalCode,
    String? city,
    String? phone,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
