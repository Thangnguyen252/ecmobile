
import 'package:ecmobile/chat_conversation_screen.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Data model for a whole conversation history entry
class ConversationHistory {
  final String title;
  final String date;
  final String time;
  final String avatar;
  List<ChatMessage> messages; // Stores the actual messages

  ConversationHistory({
    required this.title,
    required this.date,
    required this.time,
    required this.avatar,
    required this.messages,
  });
}

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  _ChatHistoryScreenState createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final List<ConversationHistory> _chatHistory = [];

  void _navigateToConversation(int? index) async {
    // If index is null, it's a new chat. Otherwise, it's an existing one.
    final initialMessages = index != null ? List<ChatMessage>.from(_chatHistory[index].messages) : null;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationScreen(initialMessages: initialMessages),
      ),
    );

    if (result != null && result is List<ChatMessage> && result.isNotEmpty) {
      final now = DateTime.now();
      final String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final String formattedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      
      // Find the first user message to use as a title
      final String title = result.firstWhere((m) => m.isUser, orElse: () => ChatMessage(text: "Cuộc trò chuyện mới", isUser: true)).text;

      setState(() {
        if (index != null) {
          // Update existing conversation
          _chatHistory[index].messages = result;
          _chatHistory[index] = ConversationHistory(
            title: _chatHistory[index].title, // Keep original title
            date: formattedDate, // Update timestamp
            time: formattedTime,
            avatar: _chatHistory[index].avatar,
            messages: result,
          );
        } else {
          // Add new conversation
          _chatHistory.insert(0, 
            ConversationHistory(
              title: title,
              date: formattedDate,
              time: formattedTime,
              avatar: "https://i.pravatar.cc/150?img=12",
              messages: result,
            )
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Lịch sử trò chuyện",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 1,
      ),
      body: _chatHistory.isEmpty
          ? const Center(
              child: Text(
                "Chưa có cuộc trò chuyện nào.\nNhấn `+` để bắt đầu.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final item = _chatHistory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    onTap: () => _navigateToConversation(index), // Tap to open existing chat
                    contentPadding: const EdgeInsets.all(12.0),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(item.avatar),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("${item.date}  ${item.time}"),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _chatHistory.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToConversation(null), // Pass null for a new chat
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
