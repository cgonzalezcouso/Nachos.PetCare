class VaccineReminder {
  final String id;
  final String petId;
  final String vaccineName;
  final DateTime dueDate;
  final String? notes;
  final bool completed;
  final DateTime createdAt;

  VaccineReminder({
    required this.id,
    required this.petId,
    required this.vaccineName,
    required this.dueDate,
    this.notes,
    this.completed = false,
    required this.createdAt,
  });

  factory VaccineReminder.fromJson(Map<String, dynamic> json) {
    return VaccineReminder(
      id: json['id'] as String,
      petId: json['petId'] as String,
      vaccineName: json['vaccineName'] as String,
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate'] as int),
      notes: json['notes'] as String?,
      completed: (json['completed'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'vaccineName': vaccineName,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'notes': notes,
      'completed': completed ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  VaccineReminder copyWith({
    String? id,
    String? petId,
    String? vaccineName,
    DateTime? dueDate,
    String? notes,
    bool? completed,
    DateTime? createdAt,
  }) {
    return VaccineReminder(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      vaccineName: vaccineName ?? this.vaccineName,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
