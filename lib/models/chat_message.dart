class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['sender_id'] as String? ?? json['senderId'] as String? ?? '',
      receiverId: json['receiver_id'] as String? ?? json['receiverId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      isRead: json['is_read'] == true || json['isRead'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
