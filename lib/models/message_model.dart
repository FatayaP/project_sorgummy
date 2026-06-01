class MessageModel {
  final String messageId;
  final String role;
  final String content;
  final DateTime timestamp;

  MessageModel({
    required this.messageId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseTs(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      try {
        final toDate = v.toDate; // may throw for Firestore Timestamp
        return toDate();
      } catch (_) {
        if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
        if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
        return DateTime.now();
      }
    }

    return MessageModel(
      messageId: id,
      role: map['role'] as String? ?? 'user',
      content: map['content'] as String? ?? '',
      timestamp: parseTs(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? messageId,
    String? role,
    String? content,
    DateTime? timestamp,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
