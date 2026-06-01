import '../models/chat_model.dart';
import '../models/message_model.dart';

/// In-memory ChatService stub to allow running without Firestore.
class ChatService {
  final Map<String, Map<String, dynamic>> _chats = {};
  final Map<String, List<Map<String, dynamic>>> _messages = {};

  Future<String> createChat({
    required String userId,
    required String title,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();
    _chats[id] = {
      'userId': userId,
      'title': title,
      'isPinned': false,
      'createdAt': now,
      'updatedAt': now,
    };
    _messages[id] = [];
    return id;
  }

  Future<void> addMessage({
    required String chatId,
    required String role,
    required String content,
  }) async {
    final now = DateTime.now();
    _messages.putIfAbsent(chatId, () => []);
    _messages[chatId]!.add({
      'role': role,
      'content': content,
      'timestamp': now,
    });
    if (_chats.containsKey(chatId)) _chats[chatId]!['updatedAt'] = now;
  }

  Future<List<ChatModel>> getChatHistory({required String userId}) async {
    final list = _chats.entries
        .where((e) => e.value['userId'] == userId)
        .map(
          (e) => ChatModel(
            chatId: e.key,
            userId: e.value['userId'] as String,
            title: e.value['title'] as String,
            isPinned: e.value['isPinned'] as bool,
            createdAt: e.value['createdAt'] as DateTime,
            updatedAt: e.value['updatedAt'] as DateTime,
          ),
        )
        .toList();
    // sort pinned first then updatedAt desc
    list.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  Future<List<MessageModel>> getMessages({required String chatId}) async {
    final msgs = _messages[chatId] ?? [];
    return msgs
        .map(
          (m) => MessageModel(
            messageId: DateTime.now().millisecondsSinceEpoch.toString(),
            role: m['role'] as String,
            content: m['content'] as String,
            timestamp: m['timestamp'] as DateTime,
          ),
        )
        .toList();
  }

  Future<void> deleteChat({required String chatId}) async {
    _messages.remove(chatId);
    _chats.remove(chatId);
  }

  Future<void> deleteAllChats({required String userId}) async {
    final keys = _chats.entries
        .where((e) => e.value['userId'] == userId)
        .map((e) => e.key)
        .toList();
    for (final k in keys) {
      _messages.remove(k);
      _chats.remove(k);
    }
  }

  Future<void> pinChat({required String chatId}) async {
    if (_chats.containsKey(chatId)) _chats[chatId]!['isPinned'] = true;
  }

  Future<void> unpinChat({required String chatId}) async {
    if (_chats.containsKey(chatId)) _chats[chatId]!['isPinned'] = false;
  }

  Future<ChatModel?> getChatById({required String chatId}) async {
    final c = _chats[chatId];
    if (c == null) return null;
    return ChatModel(
      chatId: chatId,
      userId: c['userId'] as String,
      title: c['title'] as String,
      isPinned: c['isPinned'] as bool,
      createdAt: c['createdAt'] as DateTime,
      updatedAt: c['updatedAt'] as DateTime,
    );
  }
}
