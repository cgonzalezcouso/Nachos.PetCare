class ChatConversation {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatConversation({
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  ChatConversation copyWith({
    String? otherUserId,
    String? otherUserName,
    String? otherUserAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatConversation(
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
