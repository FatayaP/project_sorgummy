import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_sidebar.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/empty_chat_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sidebarOpen = true;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  Future<void> _handleSend(BuildContext context) async {
    final provider = Provider.of<ChatProvider>(context, listen: false);
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await provider.sendMessage(content: text);
    _controller.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () async {
      final sampleReply = _buildAiReply(text);
      await provider.addAssistantMessage(content: sampleReply);
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final p = ChatProvider();
        p.loadChats();
        return p;
      },
      child: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          final isMobile = MediaQuery.of(context).size.width < 800;
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppColors.backgroundWhite,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: const BackButton(color: AppColors.textCharcoal),
                titleSpacing: 0,
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: AppColors.primaryGreen,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sorgummi AI',
                          style: TextStyle(
                            color: AppColors.textCharcoal,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Online',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isMobile
                          ? Icons.menu
                          : _sidebarOpen
                          ? Icons.chevron_left
                          : Icons.menu,
                      color: AppColors.textCharcoal,
                    ),
                    onPressed: () {
                      if (isMobile) {
                        _scaffoldKey.currentState?.openDrawer();
                      } else {
                        setState(() {
                          _sidebarOpen = !_sidebarOpen;
                        });
                      }
                    },
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(color: AppColors.cardLightGrey, height: 1.0),
                ),
              ),
              drawer: isMobile
                  ? Drawer(
                      child: SizedBox(
                        width: 280,
                        child: const ChatSidebar(isDrawer: true),
                      ),
                    )
                  : null,
              body: Row(
                children: [
                  if (!isMobile)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _sidebarOpen ? 320 : 0,
                      child: _sidebarOpen ? const ChatSidebar() : null,
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child:
                              provider.currentChatId == null &&
                                  provider.messages.isEmpty
                              ? const EmptyChatWidget()
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 24,
                                  ),
                                  itemCount: provider.messages.length,
                                  itemBuilder: (context, index) {
                                    final msg = provider.messages[index];
                                    return MessageBubble(message: msg);
                                  },
                                ),
                        ),
                        _buildInputArea(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _buildAiReply(String userMessage) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('sorgum') || lower.contains('sorghum')) {
      return 'Sorgum adalah tanaman serealia yang cocok untuk tanah kering. Jika Anda butuh tips pengelolaan, tanyakan tentang pemupukan, irigasi, atau panen.';
    }
    if (lower.contains('panen') || lower.contains('hasil')) {
      return 'Untuk panen optimal, pastikan tanaman sudah matang sempurna dan kondisi tanah stabil. Periksa juga kandungan air dan serangan hama sebelum panen.';
    }
    if (lower.contains('pupuk') || lower.contains('pemupukan')) {
      return 'Pemupukan sorgum biasanya dilakukan pada fase awal pertumbuhan. Gunakan pupuk NPK seimbang dan jangan berlebihan agar tanaman sehat.';
    }
    if (lower.contains('bagaimana') ||
        lower.contains('apa') ||
        lower.contains('mengapa') ||
        lower.contains('kenapa')) {
      return 'Pertanyaan Anda bagus. Saya akan menjawab sesuai topik yang Anda tanyakan. Silakan jelaskan lebih lanjut jika ingin detail spesifik.';
    }
    return 'Saya menerima pesan Anda: "$userMessage". Apa yang ingin Anda ketahui tentang sorgum atau budidaya lainnya?';
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.cardLightGrey, width: 1),
        ),
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
                      onSubmitted: (_) => _handleSend(context),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textCharcoal,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan Anda...',
                        hintStyle: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.mic_none_rounded,
                    color: AppColors.textLight,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _handleSend(context),
            child: const CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              radius: 20,
              child: Icon(Icons.send_rounded, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
