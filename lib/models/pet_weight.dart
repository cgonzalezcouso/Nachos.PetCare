class PetWeight {
  final String id;
  final String petId;
  final double weight;
  final DateTime date;
  final DateTime createdAt;

  PetWeight({
    required this.id,
    required this.petId,
    required this.weight,
    required this.date,
    required this.createdAt,
  });

  factory PetWeight.fromJson(Map<String, dynamic> json) {
    return PetWeight(
      id: json['id'] as String,
      petId: json['petId'] as String,
      weight: (json['weight'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'weight': weight,
      'date': date.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  PetWeight copyWith({
    String? id,
    String? petId,
    double? weight,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return PetWeight(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
