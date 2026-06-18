import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_item.dart';

class ChatSidebar extends StatelessWidget {
  final bool isDrawer;

  const ChatSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    const sidebarAccent = AppColors.primaryGreen;
    return Container(
      width: isDrawer ? 280 : 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isDrawer
            ? const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              )
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isDrawer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: Row(
                children: [
                  const Text(
                    'Riwayat Chat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF4B4B4B)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.newChat();
                      if (isDrawer) Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Obrolan Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sidebarAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE8F7E6)),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.chatHistory.length,
                    itemBuilder: (context, index) {
                      final chat = provider.chatHistory[index];
                      return ChatItem(
                        chat: chat,
                        selected: provider.currentChatId == chat.chatId,
                        onTap: () {
                          provider.loadChat(chatId: chat.chatId);
                          if (isDrawer) Navigator.of(context).pop();
                        },
                        onPin: (id) => provider.pinChat(chatId: id),
                        onUnpin: (id) => provider.unpinChat(chatId: id),
                        onDelete: (id) async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (c) {
                              return AlertDialog(
                                title: const Text('Hapus Chat'),
                                content: const Text(
                                  'Apakah Anda yakin ingin menghapus chat ini?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(c).pop(false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(c).pop(true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (ok == true) await provider.deleteChat(chatId: id);
                        },
                      );
                    },
                  ),
          ),
          const Divider(height: 1, color: Color(0xFFE8F7E6)),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) {
                          return AlertDialog(
                            title: const Text('Hapus Semua Riwayat'),
                            content: const Text(
                              'Apakah Anda yakin ingin menghapus seluruh riwayat chat?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(c).pop(false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(c).pop(true),
                                child: const Text('Hapus Semua'),
                              ),
                            ],
                          );
                        },
                      );
                      if (ok == true) await provider.deleteAllChats();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Hapus Semua Riwayat'),
                    style: TextButton.styleFrom(
                      foregroundColor: sidebarAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
