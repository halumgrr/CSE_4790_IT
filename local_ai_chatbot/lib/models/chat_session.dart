import '../models/message.dart';

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<Message> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  // Get a preview of the chat (first user message or default)
  String get preview {
    final userMessages = messages.where((m) => m.isUser).toList();
    if (userMessages.isNotEmpty) {
      return userMessages.first.text.length > 50 
          ? '${userMessages.first.text.substring(0, 50)}...'
          : userMessages.first.text;
    }
    return 'New Chat';
  }

  // Get relative time string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    List<Message>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      messages: messages ?? this.messages,
    );
  }

  // Convert ChatSession to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  // Create ChatSession from JSON
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      messages: (json['messages'] as List<dynamic>)
          .map((messageJson) => Message.fromJson(messageJson as Map<String, dynamic>))
          .toList(),
    );
  }
}