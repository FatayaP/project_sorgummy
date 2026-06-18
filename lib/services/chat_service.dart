import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  static const String _chatHistoryKey = 'chat_service_chats';
  static const String _chatMessagesKey = 'chat_service_messages';
  static const String _lastSelectedChatKey = 'chat_service_last_selected_chat';

  final Map<String, Map<String, dynamic>> _chats = {};
  final Map<String, List<Map<String, dynamic>>> _messages = {};
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final chatsJson = prefs.getString(_chatHistoryKey);
    final messagesJson = prefs.getString(_chatMessagesKey);

    if (chatsJson != null) {
      final Map<String, dynamic> decodedChats = jsonDecode(chatsJson) as Map<String, dynamic>;
      for (final entry in decodedChats.entries) {
        final chatValue = Map<String, dynamic>.from(entry.value as Map);
        _chats[entry.key] = {
          'userId': chatValue['userId'] as String,
          'title': chatValue['title'] as String,
          'isPinned': chatValue['isPinned'] as bool,
          'createdAt': DateTime.parse(chatValue['createdAt'] as String),
          'updatedAt': DateTime.parse(chatValue['updatedAt'] as String),
        };
      }
    }

    if (messagesJson != null) {
      final Map<String, dynamic> decodedMessages = jsonDecode(messagesJson) as Map<String, dynamic>;
      for (final entry in decodedMessages.entries) {
        final List<dynamic> rawMessages = entry.value as List<dynamic>;
        _messages[entry.key] = rawMessages.map((raw) {
          final messageData = Map<String, dynamic>.from(raw as Map);
          return {
            'role': messageData['role'] as String,
            'content': messageData['content'] as String,
            'timestamp': DateTime.parse(messageData['timestamp'] as String),
          };
        }).toList();
      }
    }

    _initialized = true;
  }

  Future<void> _persistData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chatHistoryKey, jsonEncode(_encodeChats()));
    await prefs.setString(_chatMessagesKey, jsonEncode(_encodeMessages()));
  }

  Future<void> _setLastSelectedChatId(String? chatId) async {
    final prefs = await SharedPreferences.getInstance();
    if (chatId == null) {
      await prefs.remove(_lastSelectedChatKey);
    } else {
      await prefs.setString(_lastSelectedChatKey, chatId);
    }
  }

  Future<String?> getLastSelectedChatId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSelectedChatKey);
  }

  Map<String, dynamic> _encodeChats() {
    return _chats.map((key, value) {
      return MapEntry(key, {
        'userId': value['userId'],
        'title': value['title'],
        'isPinned': value['isPinned'],
        'createdAt': (value['createdAt'] as DateTime).toIso8601String(),
        'updatedAt': (value['updatedAt'] as DateTime).toIso8601String(),
      });
    });
  }

  Map<String, dynamic> _encodeMessages() {
    return _messages.map((key, value) {
      return MapEntry(key, value.map((message) {
        return {
          'role': message['role'],
          'content': message['content'],
          'timestamp': (message['timestamp'] as DateTime).toIso8601String(),
        };
      }).toList());
    });
  }

  Future<String> createChat({
    required String userId,
    required String title,
  }) async {
    await _ensureInitialized();
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
    await _persistData();
    await _setLastSelectedChatId(id);
    return id;
  }

  Future<void> addMessage({
    required String chatId,
    required String role,
    required String content,
  }) async {
    await _ensureInitialized();
    final now = DateTime.now();
    _messages.putIfAbsent(chatId, () => []);
    _messages[chatId]!.add({
      'role': role,
      'content': content,
      'timestamp': now,
    });
    if (_chats.containsKey(chatId)) {
      _chats[chatId]!['updatedAt'] = now;
      await _persistData();
    }
  }

  Future<List<ChatModel>> getChatHistory({required String userId}) async {
    await _ensureInitialized();
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
    await _ensureInitialized();
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
    await _ensureInitialized();
    _messages.remove(chatId);
    _chats.remove(chatId);
    await _persistData();

    final lastSelected = await getLastSelectedChatId();
    if (lastSelected == chatId) {
      await _setLastSelectedChatId(null);
    }
  }

  Future<void> deleteAllChats({required String userId}) async {
    await _ensureInitialized();
    final keys = _chats.entries
        .where((e) => e.value['userId'] == userId)
        .map((e) => e.key)
        .toList();
    for (final k in keys) {
      _messages.remove(k);
      _chats.remove(k);
    }
    await _persistData();
    await _setLastSelectedChatId(null);
  }

  Future<void> pinChat({required String chatId}) async {
    await _ensureInitialized();
    if (_chats.containsKey(chatId)) {
      _chats[chatId]!['isPinned'] = true;
      _chats[chatId]!['updatedAt'] = DateTime.now();
      await _persistData();
    }
  }

  Future<void> unpinChat({required String chatId}) async {
    await _ensureInitialized();
    if (_chats.containsKey(chatId)) {
      _chats[chatId]!['isPinned'] = false;
      _chats[chatId]!['updatedAt'] = DateTime.now();
      await _persistData();
    }
  }

  Future<void> saveLastSelectedChatId(String chatId) async {
    await _setLastSelectedChatId(chatId);
  }

  Future<void> clearLastSelectedChatId() async {
    await _setLastSelectedChatId(null);
  }

  Future<ChatModel?> getChatById({required String chatId}) async {
    await _ensureInitialized();
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
