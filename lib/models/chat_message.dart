enum ChatRole {
  user,
  assistant,
}

class ChatMessage {
  final String id;
  final String content;
  final ChatRole role;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      role: ChatRole.values.firstWhere(
        (e) => e.toString() == 'ChatRole.${json['role']}',
        orElse: () => ChatRole.user,
      ),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 