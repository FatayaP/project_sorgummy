class ChatModel {
  final String chatId;
  final String userId;
  final String title;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    required this.chatId,
    required this.userId,
    required this.title,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseTs(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      try {
        // Firestore Timestamp has toDate()
        final toDate = v.toDate; // may throw
        return toDate();
      } catch (_) {
        if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
        if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
        return DateTime.now();
      }
    }

    return ChatModel(
      chatId: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      isPinned: map['isPinned'] as bool? ?? false,
      createdAt: parseTs(map['createdAt']),
      updatedAt: parseTs(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ChatModel copyWith({
    String? chatId,
    String? userId,
    String? title,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
