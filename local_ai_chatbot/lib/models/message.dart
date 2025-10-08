class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert Message to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // Create Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }

  @override
  String toString() {
    return 'Message(text: $text, isUser: $isUser, timestamp: $timestamp)';
  }
}