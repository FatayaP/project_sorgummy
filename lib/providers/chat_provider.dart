import 'package:flutter/material.dart';
import '../data/helpers/shared_prefs_helper.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService();

  List<ChatModel> chatHistory = [];
  ChatModel? selectedChat;
  String? currentChatId;
  List<MessageModel> messages = [];
  bool isLoading = false;

  // Temporary guest user id for local chat flow.
  // This avoids requiring Firebase auth while the app is running in web/debug mode.
  String get _userId => 'guest_user';

  Future<void> loadChats() async {
    isLoading = true;
    notifyListeners();
    chatHistory = await _service.getChatHistory(userId: _userId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> createChat({required String title}) async {
    final chatId = await _service.createChat(userId: _userId, title: title);
    currentChatId = chatId;
    selectedChat = await _service.getChatById(chatId: chatId);
    messages = [];
    await loadChats();
    notifyListeners();
  }

  Future<void> sendMessage({required String content}) async {
    if (currentChatId == null) {
      final title = content.trim();
      final shortTitle = title.length > 64
          ? '${title.substring(0, 61)}...'
          : title;
      await createChat(title: shortTitle);
    }

    if (currentChatId == null) return;

    await _service.addMessage(
      chatId: currentChatId!,
      role: 'user',
      content: content,
    );
    messages.add(
      MessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'user',
        content: content,
        timestamp: DateTime.now(),
      ),
    );

    await SharedPrefsHelper.saveActivity('Menggunakan fitur Chat AI');
    notifyListeners();
  }

  Future<void> addAssistantMessage({required String content}) async {
    if (currentChatId == null) return;
    await _service.addMessage(
      chatId: currentChatId!,
      role: 'assistant',
      content: content,
    );
    messages.add(
      MessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: content,
        timestamp: DateTime.now(),
      ),
    );
    await loadChats();
    notifyListeners();
  }

  Future<void> loadChat({required String chatId}) async {
    isLoading = true;
    notifyListeners();
    currentChatId = chatId;
    selectedChat = await _service.getChatById(chatId: chatId);
    messages = await _service.getMessages(chatId: chatId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteChat({required String chatId}) async {
    await _service.deleteChat(chatId: chatId);
    if (currentChatId == chatId) newChat();
    await loadChats();
    notifyListeners();
  }

  Future<void> deleteAllChats() async {
    await _service.deleteAllChats(userId: _userId);
    newChat();
    await loadChats();
    notifyListeners();
  }

  Future<void> pinChat({required String chatId}) async {
    await _service.pinChat(chatId: chatId);
    await loadChats();
    notifyListeners();
  }

  Future<void> unpinChat({required String chatId}) async {
    await _service.unpinChat(chatId: chatId);
    await loadChats();
    notifyListeners();
  }

  void newChat() {
    currentChatId = null;
    selectedChat = null;
    messages = [];
    notifyListeners();
  }
}
