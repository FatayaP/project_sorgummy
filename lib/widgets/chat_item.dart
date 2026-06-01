import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/chat_model.dart';

typedef ChatItemAction = void Function(String chatId);

class ChatItem extends StatelessWidget {
  final ChatModel chat;
  final bool selected;
  final VoidCallback onTap;
  final ChatItemAction onPin;
  final ChatItemAction onUnpin;
  final ChatItemAction onDelete;

  const ChatItem({
    Key? key,
    required this.chat,
    required this.onTap,
    required this.onPin,
    required this.onUnpin,
    required this.onDelete,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const selectedBg = Color(0xFFE8F7E6);
    const selectedText = AppColors.primaryGreen;

    return ListTile(
      selected: selected,
      selectedTileColor: selectedBg,
      selectedColor: selectedText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: chat.isPinned ? const Icon(Icons.push_pin, size: 18) : null,
      title: Text(
        chat.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: selected ? selectedText : null,
          fontWeight: selected ? FontWeight.w600 : null,
        ),
      ),
      subtitle: Text(
        _formatTime(chat.updatedAt),
        style: TextStyle(
          fontSize: 12,
          color: selected ? selectedText.withOpacity(0.8) : Colors.black54,
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'pin') onPin(chat.chatId);
          if (v == 'unpin') onUnpin(chat.chatId);
          if (v == 'delete') onDelete(chat.chatId);
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: chat.isPinned ? 'unpin' : 'pin',
            child: Text(chat.isPinned ? 'Unpin Chat' : 'Pin Chat'),
          ),
          const PopupMenuItem(value: 'delete', child: Text('Hapus Chat')),
        ],
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
