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
      final sampleReply = _buildAiReply(text, provider.aiModelMode);
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
                        Text(
                          'Mode Aktif: ${_modeLabel(provider.aiModelMode)}',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.smart_toy_outlined,
                      color: AppColors.textCharcoal,
                    ),
                    tooltip: 'Mode Respons AI',
                    onPressed: () {
                      _showAiModeDialog(context, provider);
                    },
                  ),
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

  void _showAiModeDialog(BuildContext context, ChatProvider provider) {
    showDialog<void>(
      context: context,
      builder: (context) {
        String selectedMode = provider.aiModelMode;
        return AlertDialog(
          title: const Text('Mode Respons AI'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Cepat'),
                    subtitle: const Text('Jawaban singkat dan langsung ke inti.'),
                    value: 'cepat',
                    groupValue: selectedMode,
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        selectedMode = value;
                      });
                      await provider.setAiModelMode(value);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mode respons AI berhasil diperbarui'),
                          ),
                        );
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Informatif'),
                    subtitle: const Text('Penjelasan seimbang dan mudah dipahami.'),
                    value: 'informatif',
                    groupValue: selectedMode,
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        selectedMode = value;
                      });
                      await provider.setAiModelMode(value);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mode respons AI berhasil diperbarui'),
                          ),
                        );
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Mendalam'),
                    subtitle: const Text('Jawaban detail, lengkap, dan terstruktur.'),
                    value: 'mendalam',
                    groupValue: selectedMode,
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        selectedMode = value;
                      });
                      await provider.setAiModelMode(value);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mode respons AI berhasil diperbarui'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _modeLabel(String mode) {
    if (mode == 'cepat') return 'Cepat';
    if (mode == 'mendalam') return 'Mendalam';
    return 'Informatif';
  }

  String _buildAiReply(String userMessage, String mode) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('sorgum') || lower.contains('sorghum')) {
      if (mode == 'cepat') {
        return 'Sorgum adalah tanaman serealia yang cocok untuk tanah kering. Untuk penjelasan cepat, tanyakan langsung mengenai budidaya atau produk sorgum.';
      }
      if (mode == 'mendalam') {
        return '''Sorgum adalah tanaman serealia yang cocok untuk tanah kering. Berikut beberapa poin penting:

1. Sorgum tahan kekeringan dan cocok untuk lahan terbatas.
2. Dapat dipakai untuk tepung, pakan ternak, dan industri makanan.
3. Mendukung diversifikasi pangan lokal dan peluang UMKM.

Tanya tentang pemupukan, irigasi, atau panen untuk detail lebih lanjut.''';
      }
      return 'Sorgum adalah tanaman serealia yang cocok untuk tanah kering. Jika Anda ingin informasi lebih lanjut, tanyakan tentang pemupukan, irigasi, atau panen.';
    }

    if (lower.contains('panen') || lower.contains('hasil')) {
      if (mode == 'cepat') {
        return 'Panen sorgum terbaik kalau tanaman sudah matang dan kondisi tanah stabil. Cek kelembapan dan serangan hama terlebih dahulu.';
      }
      if (mode == 'mendalam') {
        return '''Untuk panen optimal:

1. Pastikan bulir sorgum kering dan keras.
2. Periksa kadar air sebelum panen.
3. Lakukan panen pagi hari untuk mengurangi kerusakan.
4. Simpan hasil panen di tempat kering.

Langkah ini membantu menjaga kualitas dan mengurangi risiko jamur.''';
      }
      return 'Untuk panen optimal, pastikan tanaman sudah matang sempurna dan kondisi tanah stabil. Periksa juga kandungan air dan serangan hama sebelum panen.';
    }

    if (lower.contains('pupuk') || lower.contains('pemupukan')) {
      if (mode == 'cepat') {
        return 'Pemupukan sorgum umumnya dilakukan sejak awal pertumbuhan dengan pupuk NPK seimbang. Jangan terlalu berlebihan agar pertumbuhan sehat.';
      }
      if (mode == 'mendalam') {
        return '''Pemupukan sorgum biasanya dilakukan pada fase awal pertumbuhan. Pertimbangkan:

1. Gunakan NPK seimbang.
2. Berikan pupuk dasar sebelum tanam.
3. Tambahkan pupuk susulan saat vegetatif.
4. Hindari pemupukan berlebihan agar tidak merusak akar.

Langkah ini membantu tanaman tumbuh kuat dan menghasilkan panen lebih baik.''';
      }
      return 'Pemupukan sorgum biasanya dilakukan pada fase awal pertumbuhan. Gunakan pupuk NPK seimbang dan jangan berlebihan agar tanaman sehat.';
    }

    if (lower.contains('bagaimana') ||
        lower.contains('apa') ||
        lower.contains('mengapa') ||
        lower.contains('kenapa')) {
      if (mode == 'cepat') {
        return 'Pertanyaan Anda bagus. Saya akan memberikan jawaban singkat dan langsung sesuai topik yang Anda tanyakan.';
      }
      if (mode == 'mendalam') {
        return 'Pertanyaan Anda bagus. Saya akan menjawab secara terstruktur dan mendetail. Jika perlu, saya juga bisa menyajikan poin-poin, contoh, atau langkah-langkah.';
      }
      return 'Pertanyaan Anda bagus. Saya akan menjawab sesuai topik yang Anda tanyakan. Silakan jelaskan lebih lanjut jika ingin detail spesifik.';
    }

    if (mode == 'cepat') {
      return 'Saya menerima pesan Anda: "$userMessage". Silakan tanyakan lebih lanjut jika Anda ingin informasi cepat tentang sorgum atau budidaya.';
    }

    if (mode == 'mendalam') {
      return '''Saya menerima pesan Anda: "$userMessage". Berikut beberapa hal yang bisa dijelaskan:

1. Fokus pada topik sorgum.
2. Sertakan contoh atau langkah bila relevan.
3. Saya bisa menjelaskan lebih mendalam tentang budidaya, produk, atau peluang usaha.''';
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
