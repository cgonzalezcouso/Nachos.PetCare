class VeterinaryReport {
  final String id;
  final String petId;
  final DateTime visitDate;
  final String? vetName;
  final String? diagnosis;
  final String? treatment;
  final String? notes;
  final DateTime createdAt;

  VeterinaryReport({
    required this.id,
    required this.petId,
    required this.visitDate,
    this.vetName,
    this.diagnosis,
    this.treatment,
    this.notes,
    required this.createdAt,
  });

  factory VeterinaryReport.fromJson(Map<String, dynamic> json) {
    return VeterinaryReport(
      id: json['id'] as String,
      petId: json['petId'] as String,
      visitDate: DateTime.fromMillisecondsSinceEpoch(json['visitDate'] as int),
      vetName: json['vetName'] as String?,
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'visitDate': visitDate.millisecondsSinceEpoch,
      'vetName': vetName,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  VeterinaryReport copyWith({
    String? id,
    String? petId,
    DateTime? visitDate,
    String? vetName,
    String? diagnosis,
    String? treatment,
    String? notes,
    DateTime? createdAt,
  }) {
    return VeterinaryReport(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      visitDate: visitDate ?? this.visitDate,
      vetName: vetName ?? this.vetName,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
