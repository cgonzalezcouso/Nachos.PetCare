class Reminder {
  final String id;
  final String userId;
  final String title;
  final DateTime dueDate;
  final String? notes;
  final bool completed;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.dueDate,
    this.notes,
    this.completed = false,
    required this.createdAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      userId: (json['userId'] ?? json['user_id']) as String,
      title: json['title'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'] as int)
          : DateTime.parse(json['due_date'] as String).toLocal(),
      notes: json['notes'] as String?,
      completed: json['completed'] is bool
          ? json['completed'] as bool
          : (json['completed'] is int ? (json['completed'] as int) == 1 : false),
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'due_date': dueDate.toUtc().toIso8601String(),
      'notes': notes,
      'completed': completed,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'notes': notes,
      'completed': completed ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  Reminder copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? dueDate,
    String? notes,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
