import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nachos_pet_care_flutter/models/chat_message.dart';
import 'package:nachos_pet_care_flutter/models/chat_conversation.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // En memoria para simulación y caching
  final List<ChatMessage> _mockMessages = [];
  final Map<String, StreamController<List<ChatMessage>>> _messageStreams = {};
  final Map<String, StreamController<bool>> _typingStreams = {};
  final StreamController<List<ChatConversation>> _conversationStream = StreamController<List<ChatConversation>>.broadcast();



  // Id del usuario actual (o fallback si no hay sesión)
  String get _currentUserId {
    try {
      return _supabase.auth.currentUser?.id ?? 'current_user_id';
    } catch (_) {
      return 'current_user_id';
    }
  }

  bool _isCurrentUser(String id) {
    final currentId = _currentUserId;
    return id == 'current_user_id' || id == currentId;
  }

  static const String _storageKey = 'nachos_chat_messages_v2';

  ChatService() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = json.decode(jsonStr);
        _mockMessages.clear();
        _mockMessages.addAll(decoded.map((item) => ChatMessage.fromJson(item as Map<String, dynamic>)));
      } else {
        _initMockData();
      }
    } catch (_) {
      _initMockData();
    }
    _notifyConversationsChanged();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = json.encode(_mockMessages.map((m) => m.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {
      // Ignorar errores
    }
  }

  void _initMockData() {
    // Inicializar algunas conversaciones de demostración para que el chat se vea vivo y lleno al instante
    final now = DateTime.now();

    // Mensajes iniciales de Juan Pérez (dueño de Nachito)
    _mockMessages.addAll([
      ChatMessage(
        id: 'msg_juan_1',
        senderId: 'mock-owner-1',
        receiverId: 'current_user_id',
        text: '¡Hola! Vi que le diste a seguir al perfil de Nachito. ¡Muchas gracias por el cariño! 🐾 ¿Tienes alguna mascota tú también?',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ]);

    // Mensajes iniciales de María Gómez (dueña de Kira)
    _mockMessages.addAll([
      ChatMessage(
        id: 'msg_maria_1',
        senderId: 'mock-owner-2',
        receiverId: 'current_user_id',
        text: 'Hola. Kira es un poco tímida, pero le encantan las caricias una vez que entra en confianza. ¿Has probado los snacks de salmón que subí en su álbum? 🐱',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
    ]);

    // Mensaje inicial de Carlos Ruiz (dueño de Copito)
    _mockMessages.addAll([
      ChatMessage(
        id: 'msg_carlos_1',
        senderId: 'mock-owner-3',
        receiverId: 'current_user_id',
        text: '¡Hola! Qué buena comunidad es Nachos. ¿Sueles llevar a tus mascotas al parque del norte para socializar?',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ]);

    _saveToStorage();
    _notifyConversationsChanged();
  }

  // Notificar cambios en las conversaciones agregadas
  void _notifyConversationsChanged() {
    final conversations = _buildConversationsList();
    _conversationStream.add(conversations);
  }

  List<ChatConversation> _buildConversationsList() {
    final Map<String, List<ChatMessage>> grouped = {};

    // Agrupar todos los mensajes por interlocutor
    for (var msg in _mockMessages) {
      final otherId = _isCurrentUser(msg.senderId) ? msg.receiverId : msg.senderId;
      grouped.putIfAbsent(otherId, () => []).add(msg);
    }

    final List<ChatConversation> list = [];

    // Nombres y avatares simulados de la base de datos
    final Map<String, String> userNames = {
      'mock-owner-1': 'Juan Pérez',
      'mock-owner-2': 'María Gómez',
      'mock-owner-3': 'Carlos Ruiz',
      'mock-owner-4': 'Laura Torres',
    };

    final Map<String, String> userAvatars = {
      'mock-owner-1': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      'mock-owner-2': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      'mock-owner-3': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
      'mock-owner-4': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
    };

    grouped.forEach((otherId, msgs) {
      msgs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final lastMsg = msgs.first;
      final unread = msgs.where((m) => m.senderId == otherId && !m.isRead).length;

      list.add(ChatConversation(
        otherUserId: otherId,
        otherUserName: userNames[otherId] ?? 'Amigo de la Comunidad',
        otherUserAvatar: userAvatars[otherId],
        lastMessage: lastMsg.text,
        lastMessageTime: lastMsg.createdAt,
        unreadCount: unread,
      ));
    });

    // Ordenar de más reciente a más antiguo
    list.sort((a, b) {
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });

    return list;
  }

  // ── Petición de Conversaciones Abiertas ──────────────────────────────────────
  Stream<List<ChatConversation>> getConversations() {
    // Si Supabase está configurado, podemos leer de la BD. En su defecto, devolvemos el stream reactivo de simulación.
    Timer.run(() => _notifyConversationsChanged());
    return _conversationStream.stream;
  }

  // Obtener mensajes de un chat específico
  Stream<List<ChatMessage>> getMessages(String otherUserId) {
    final controller = _messageStreams.putIfAbsent(otherUserId, () => StreamController<List<ChatMessage>>.broadcast());
    // Programar la emisión inicial asíncronamente para que el listener (StreamBuilder) tenga tiempo de suscribirse primero
    scheduleMicrotask(() => _notifyMessagesChanged(otherUserId));
    return controller.stream;
  }

  // Obtener si el interlocutor está escribiendo
  Stream<bool> getIsTyping(String otherUserId) {
    final controller = _typingStreams.putIfAbsent(otherUserId, () => StreamController<bool>.broadcast());
    return controller.stream;
  }

  // Marcar todos los mensajes de una conversación como leídos
  void markAsRead(String otherUserId) {
    bool changed = false;

    for (var i = 0; i < _mockMessages.length; i++) {
      final msg = _mockMessages[i];
      if (msg.senderId == otherUserId && _isCurrentUser(msg.receiverId) && !msg.isRead) {
        _mockMessages[i] = msg.copyWith(isRead: true);
        changed = true;
      }
    }

    if (changed) {
      _saveToStorage();
      _notifyMessagesChanged(otherUserId);
      _notifyConversationsChanged();
    }
  }

  void _notifyMessagesChanged(String otherUserId) {
    final messages = _mockMessages.where((m) =>
        (_isCurrentUser(m.senderId) && m.receiverId == otherUserId) ||
        (m.senderId == otherUserId && _isCurrentUser(m.receiverId)))
        .toList();

    // Ordenar de más antiguo a más reciente
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final controller = _messageStreams[otherUserId];
    if (controller != null) {
      controller.add(messages);
    }
  }

  // ── Enviar Mensaje ─────────────────────────────────────────────────────────
  Future<void> sendMessage({
    required String receiverId,
    required String text,
    required String receiverName,
  }) async {
    final currentId = _currentUserId;
    final now = DateTime.now();

    final newMessage = ChatMessage(
      id: 'msg_local_${now.millisecondsSinceEpoch}_${Random().nextInt(1000)}',
      senderId: currentId,
      receiverId: receiverId,
      text: text,
      createdAt: now,
      isRead: true, // Mis propios mensajes están "leídos"
    );

    _mockMessages.add(newMessage);
    _saveToStorage();
    _notifyMessagesChanged(receiverId);
    _notifyConversationsChanged();

    // Simulación de respuesta automatizada adorable de la comunidad en 1.5s
    _simulateCommunityResponse(receiverId, receiverName, text);
  }

  void _simulateCommunityResponse(String receiverId, String receiverName, String userText) {
    final typingController = _typingStreams.putIfAbsent(receiverId, () => StreamController<bool>.broadcast());

    // Esperar 800ms antes de mostrar que está escribiendo
    Timer(const Duration(milliseconds: 600), () {
      typingController.add(true);

      // Esperar 1.8s simulando el tecleado para dar sensación real
      Timer(const Duration(milliseconds: 1800), () {
        typingController.add(false);

        // Respuestas inteligentes basadas en palabras clave o genéricas cariñosas
        final responses = [
          '¡Hola! Qué alegría saludarte. Me parece genial conectar con otros dueños de mascotas. 😊',
          '¡Totalmente de acuerdo! Las mascotas son parte de nuestra familia 🐾. ¿Qué edad tiene el tuyo?',
          'Qué buen consejo. Lo tendré muy en cuenta para la próxima visita al parque. ¡Un saludo! 🐶',
          '¡Ja, ja, ja! Sí, son de lo más traviesos, pero nos llenan la vida de alegría. ❤️',
          '¡Me encantaría! Podríamos planificar un paseo por el parque de mascotas este fin de semana. ¿Te viene bien el sábado? 🐕',
          'Muchas gracias por escribirme. Qué genial aplicación es esta para cuidarlos mejor.',
        ];

        final textLower = userText.toLowerCase();
        String responseText = responses[Random().nextInt(responses.length)];

        if (textLower.contains('hola') || textLower.contains('buenas')) {
          responseText = '¡Hola! ¿Cómo estás? Me alegro un montón de hablar contigo. 🐾';
        } else if (textLower.contains('edad') || textLower.contains('años') || textLower.contains('tiempo')) {
          responseText = 'El mío cumplirá pronto otro año más de felicidad y travesuras. ¡El tiempo vuela a su lado! 🥰';
        } else if (textLower.contains('parque') || textLower.contains('paseo') || textLower.contains('quedar')) {
          responseText = '¡Eso suena increíble! Nos encanta socializar con otros perritos y dueños. Dinos cuándo y nos apuntamos de inmediato. 🐕✨';
        } else if (textLower.contains('comida') || textLower.contains('pienso') || textLower.contains('comer')) {
          responseText = 'Le encantan las recetas de salmón y arroz, le sientan de maravilla y le dejan el pelo súper brillante. 🐟🐾';
        }

        final responseMessage = ChatMessage(
          id: 'msg_sim_${DateTime.now().millisecondsSinceEpoch}',
          senderId: receiverId,
          receiverId: 'current_user_id',
          text: responseText,
          createdAt: DateTime.now(),
          isRead: false,
        );

        _mockMessages.add(responseMessage);
        _saveToStorage();
        _notifyMessagesChanged(receiverId);
        _notifyConversationsChanged();
      });
    });
  }

  // Contar el total de mensajes sin leer del usuario para mostrar en el badge de la barra de inicio
  Stream<int> getUnreadCountStream() {
    final controller = StreamController<int>.broadcast();
    
    // Escuchar cambios de conversaciones para recalcular
    getConversations().listen((convs) {
      final total = convs.fold<int>(0, (sum, c) => sum + c.unreadCount);
      controller.add(total);
    });

    return controller.stream;
  }
}
