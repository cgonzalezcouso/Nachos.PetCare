class PublicPetPhoto {
  final String id;
  final String petId;
  final String photoPath;
  final DateTime date;
  final String? notes;

  PublicPetPhoto({
    required this.id,
    required this.petId,
    required this.photoPath,
    required this.date,
    this.notes,
  });

  factory PublicPetPhoto.fromJson(Map<String, dynamic> json) {
    return PublicPetPhoto(
      id: json['id'] as String,
      petId: json['pet_id'] as String? ?? json['petId'] as String? ?? '',
      photoPath: json['photo_path'] as String? ?? json['photoPath'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'photo_path': photoPath,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }
}
