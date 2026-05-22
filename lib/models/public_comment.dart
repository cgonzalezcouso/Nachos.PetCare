class PublicComment {
  final String id;
  final String photoId;
  final String userId;
  final String userName;
  final String commentText;
  final DateTime createdAt;

  PublicComment({
    required this.id,
    required this.photoId,
    required this.userId,
    required this.userName,
    required this.commentText,
    required this.createdAt,
  });

  factory PublicComment.fromJson(Map<String, dynamic> json) {
    return PublicComment(
      id: json['id'] as String,
      photoId: json['photo_id'] as String? ?? json['photoId'] as String? ?? '',
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      userName: json['user_name'] as String? ?? json['userName'] as String? ?? 'Amigo de Nachos',
      commentText: json['comment_text'] as String? ?? json['commentText'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo_id': photoId,
      'user_id': userId,
      'user_name': userName,
      'comment_text': commentText,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
