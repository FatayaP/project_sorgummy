class ChatMessage {
  final String id;
  final String sender; // 'user' or 'ai'
  final String text;
  final String time;
  final String? image;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'time': time,
      'image': image,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      sender: map['sender'] as String,
      text: map['text'] as String,
      time: map['time'] as String,
      image: map['image'] as String?,
    );
  }
}


