class VetInvitation {
  final String id;
  final String petId;
  final String petName;
  final String? petPhoto;
  final String ownerName;
  final String vetEmail;
  final String clinicName;
  final String status; // 'pending', 'accepted', 'declined'
  final DateTime createdAt;

  VetInvitation({
    required this.id,
    required this.petId,
    required this.petName,
    this.petPhoto,
    required this.ownerName,
    required this.vetEmail,
    required this.clinicName,
    required this.status,
    required this.createdAt,
  });

  factory VetInvitation.fromJson(Map<String, dynamic> json) {
    return VetInvitation(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      petName: json['pet_name'] as String,
      petPhoto: json['pet_photo'] as String?,
      ownerName: json['owner_name'] as String,
      vetEmail: json['vet_email'] as String,
      clinicName: json['clinic_name'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'pet_name': petName,
      'pet_photo': petPhoto,
      'owner_name': ownerName,
      'vet_email': vetEmail,
      'clinic_name': clinicName,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  VetInvitation copyWith({
    String? id,
    String? petId,
    String? petName,
    String? petPhoto,
    String? ownerName,
    String? vetEmail,
    String? clinicName,
    String? status,
    DateTime? createdAt,
  }) {
    return VetInvitation(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petPhoto: petPhoto ?? this.petPhoto,
      ownerName: ownerName ?? this.ownerName,
      vetEmail: vetEmail ?? this.vetEmail,
      clinicName: clinicName ?? this.clinicName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
