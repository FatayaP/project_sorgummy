import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<ChatMessage> _messages = [
    ChatMessage(id: '1', sender: 'ai', text: 'Halo! Saya Sorgummi AI ✨\nAda yang ingin Anda tanyakan tentang sorgum?', time: '09:30'),
    ChatMessage(id: '2', sender: 'user', text: 'Daun sorgum saya menguning. itu kenapa ya?', time: '09:31'),
    ChatMessage(id: '3', sender: 'ai', text: 'Bisa jadi karena kekurangan unsur hara, serangan hama, atau kondisi tanah. Bisa kirim foto daun untuk analisis lebih akurat.', time: '09:31'),
    ChatMessage(id: '4', sender: 'user', text: '', time: '09:32', image: 'assets/images/leaf.png'), 
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Fungsi aktif untuk mengirim pesan rill tanpa bantuan package intl
  void _sendMessage() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;

    // Membuat format waktu HH:mm secara manual agar aman di Flutter Web/Chrome
    final now = DateTime.now();
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    final String currentTime = '$hour:$minute';

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: 'user',
          text: text,
          time: currentTime,
        ),
      );
    });

    _controller.clear();
    _scrollToBottom();
  }

  // Efek scroll otomatis ke bawah setelah mengirim pesan baru
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: AppColors.textCharcoal), // Berfungsi rill kembali ke Home
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                child: const Icon(Icons.smart_toy_rounded, color: AppColors.primaryGreen, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sorgummi AI', style: TextStyle(color: AppColors.textCharcoal, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      const Text('Online', style: TextStyle(color: AppColors.textLight, fontSize: 11)),
                    ],
                  )
                ],
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.cardLightGrey, height: 1.0),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.sender == 'user';
                  return _buildChatBubble(msg, isUser);
                },
              ),
            ),
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
                    ],
                    border: isUser ? null : Border.all(color: AppColors.cardLightGrey, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (msg.text.isNotEmpty)
                        Text(
                          msg.text, 
                          style: TextStyle(color: isUser ? Colors.white : AppColors.textCharcoal, fontSize: 14, height: 1.4)
                        ),
                      if (msg.image != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              msg.image!, 
                              width: 200, 
                              fit: BoxFit.cover, 
                              errorBuilder: (c, e, s) => Container(
                                width: 200, 
                                height: 150, 
                                color: Colors.green.shade50,
                                child: const Icon(Icons.broken_image_outlined, color: AppColors.primaryGreen),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // PERBAIKAN: Menggunakan properti parameter legal di dalam EdgeInsets.only()
                Padding(
                  padding: EdgeInsets.only(
                    left: isUser ? 0 : 4, 
                    right: isUser ? 4 : 0,
                  ),
                  child: Text(msg.time, style: const TextStyle(color: AppColors.textLight, fontSize: 10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white, 
        border: Border(top: BorderSide(color: AppColors.cardLightGrey, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardLightGrey.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardLightGrey, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: const TextStyle(fontSize: 14, color: AppColors.textCharcoal),
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan Anda...',
                        hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const Icon(Icons.mic_none_rounded, color: AppColors.textLight, size: 22),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              radius: 20,
              child: Icon(Icons.send_rounded, color: Colors.white, size: 16),
            ),
          )
        ],
      ),
    );
  }
}