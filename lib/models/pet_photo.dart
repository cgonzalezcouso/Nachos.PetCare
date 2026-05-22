class PetPhoto {
  final String id;
  final String petId;
  final String photoPath;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  PetPhoto({
    required this.id,
    required this.petId,
    required this.photoPath,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  factory PetPhoto.fromJson(Map<String, dynamic> json) {
    return PetPhoto(
      id: json['id'] as String,
      petId: json['petId'] as String,
      photoPath: json['photoPath'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      notes: json['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'photoPath': photoPath,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  PetPhoto copyWith({
    String? id,
    String? petId,
    String? photoPath,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return PetPhoto(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      photoPath: photoPath ?? this.photoPath,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
