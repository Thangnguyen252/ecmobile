import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  String content;
  String role; // 'user' hoặc 'ai'
  String timestamp;

  ChatMessage({
    required this.content,
    required this.role,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'role': role,
    'timestamp': timestamp,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] ?? '',
      role: json['role'] ?? 'user',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class ChatSession {
  String sessionId;
  String sessionName;
  String customerName;
  String userId;
  String lastUpdated;
  List<ChatMessage> messages;

  ChatSession({
    required this.sessionId,
    required this.sessionName,
    required this.customerName,
    required this.userId,
    required this.lastUpdated,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'sessionName': sessionName,
    'customerName': customerName,
    'userId': userId,
    'lastUpdated': lastUpdated,
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory ChatSession.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var list = data['messages'] as List? ?? [];
    List<ChatMessage> messagesList = list.map((i) => ChatMessage.fromJson(i)).toList();

    return ChatSession(
      sessionId: doc.id,
      sessionName: data['sessionName'] ?? 'Cuộc trò chuyện mới',
      customerName: data['customerName'] ?? '',
      userId: data['userId'] ?? '',
      lastUpdated: data['lastUpdated'] ?? '',
      messages: messagesList,
    );
  }
}