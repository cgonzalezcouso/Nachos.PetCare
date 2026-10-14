import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nachos_pet_care_flutter/models/chat_message.dart';
import 'package:nachos_pet_care_flutter/services/chat_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/l10n/app_strings.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = getIt<ChatService>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    
    // Marcar como leído al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatService.markAsRead(widget.userId);
      _scrollToBottom(animated: false);
    });
  }

  void _onTextChanged() {
    final textNotEmpty = _messageController.text.trim().isNotEmpty;
    if (textNotEmpty != _canSend) {
      setState(() => _canSend = textNotEmpty);
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _chatService.sendMessage(
      receiverId: widget.userId,
      text: text,
      receiverName: widget.userName,
    );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                widget.userName.substring(0, min(2, widget.userName.length)).toUpperCase(),
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder<bool>(
                    stream: _chatService.getIsTyping(widget.userId),
                    builder: (context, snapshot) {
                      final isTyping = snapshot.data ?? false;
                      return Text(
                        isTyping ? strings.typing : 'En línea',
                        style: TextStyle(
                          fontSize: 11,
                          color: isTyping ? Colors.green : Colors.grey[600],
                          fontWeight: isTyping ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 💬 Stream de Burbujas de Mensaje
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _chatService.getMessages(widget.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data ?? [];
                  
                  // Auto-scrollear al final al cargar nuevos mensajes
                  if (messages.isNotEmpty) {
                    _scrollToBottom(animated: false);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        // ✍️ Mostrar burbuja de escribiendo al final si procede
                        return StreamBuilder<bool>(
                          stream: _chatService.getIsTyping(widget.userId),
                          builder: (context, snapshot) {
                            final isTyping = snapshot.data ?? false;
                            if (!isTyping) return const SizedBox.shrink();
                            return _buildTypingBubble(colorScheme);
                          },
                        );
                      }

                      final msg = messages[index];
                      final isMe = msg.senderId == 'current_user_id';
                      return _buildMessageBubble(msg, isMe, colorScheme);
                    },
                  );
                },
              ),
            ),

            // ✍️ Input de Texto inferior flotante
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.sentiment_satisfied_alt, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: strings.typeMessage,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _canSend ? _handleSend : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: _canSend
                            ? LinearGradient(
                                colors: [colorScheme.primary, colorScheme.secondary],
                              )
                            : null,
                        color: _canSend ? null : Colors.grey[300],
                        shape: BoxShape.circle,
                        boxShadow: _canSend
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: _canSend ? Colors.white : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe, ColorScheme colorScheme) {
    final Alignment alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final double leftPadding = isMe ? 64.0 : 0.0;
    final double rightPadding = isMe ? 0.0 : 64.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            gradient: isMe
                ? LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primary.withRed(150)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isMe ? null : colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                msg.text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimeOfDay(msg.createdAt),
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.grey[500],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(right: 64.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Escribiendo',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const SizedBox(width: 4),
              _buildDotIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotIndicator() {
    return const SizedBox(
      width: 14,
      child: Text(
        '...',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatTimeOfDay(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}
