
import 'package:ecmobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Data model for a single message
class ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? suggestions;

  ChatMessage({required this.text, required this.isUser, this.suggestions});
}

class ChatConversationScreen extends StatefulWidget {
  final List<ChatMessage>? initialMessages;

  const ChatConversationScreen({Key? key, this.initialMessages}) : super(key: key);

  @override
  _ChatConversationScreenState createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessages != null && widget.initialMessages!.isNotEmpty) {
      // This is an existing chat, don't autofocus
      _messages.addAll(widget.initialMessages!);
    } else {
      // This is a new chat, add initial message and autofocus the text field
      _addBotMessage(
        "Chào bạn! 👋 Tôi là Trợ lý Ảo Faker. "
        "Tôi ở đây để giúp bạn tìm ra những sản phẩm phù hợp nhất với nhu cầu và ngân sách của bạn. "
        "Để bắt đầu, bạn đang quan tâm đến sản phẩm nào?",
        suggestions: ["Điện thoại", "Laptop", "Đồng hồ thông minh", "Phụ kiện"],
      );
      // Autofocus when starting a new chat
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addBotMessage(String text, {List<String>? suggestions}) {
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: false, suggestions: suggestions));
    });
  }

  void _handleSubmitted(String text, {bool fromSuggestion = false}) {
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      // When submitting, hide previous suggestions
      if (_messages.isNotEmpty && _messages.first.suggestions != null) {
        _messages.first = ChatMessage(text: _messages.first.text, isUser: false, suggestions: null);
      }
      _messages.insert(0, ChatMessage(text: text, isUser: true));
    });

    // If submitted from a suggestion, keep the keyboard open
    if (fromSuggestion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }

    // Simulate bot response
    Future.delayed(const Duration(milliseconds: 500), () {
      String botResponse;
      if (text.toLowerCase().contains('laptop')) {
        botResponse = "Laptop là thế mạnh của chúng tôi! Bạn tìm laptop để chơi game hay làm việc văn phòng?";
      } else if (text.toLowerCase().contains('điện thoại')) {
        botResponse = "Tuyệt vời! Bạn có quan tâm đến thương hiệu nào cụ thể không, ví dụ như Samsung hay iPhone?";
      } else {
        botResponse = "Cảm ơn bạn. Để tư vấn tốt hơn, bạn có thể cho tôi biết ngân sách dự kiến của bạn là bao nhiêu không?";
      }
      _addBotMessage(botResponse);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(_messages),
        ),
        title: const Row(
          children: [
            Text("🏆", style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text("AI Hỗ trợ Tư vấn", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _ChatMessageBubble(
                message: _messages[index],
                onSuggestionTap: (text) => _handleSubmitted(text, fromSuggestion: true),
              ),
            ),
          ),
          const Divider(height: 1.0),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              Flexible(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode, // The FocusNode is already assigned
                  onSubmitted: _handleSubmitted,
                  decoration: const InputDecoration.collapsed(
                    hintText: "Nhập câu hỏi của bạn...",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The _ChatMessageBubble widget remains mostly the same...
class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({required this.message, this.onSuggestionTap});

  final ChatMessage message;
  final Function(String)? onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!message.isUser)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12")), // Bot avatar
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: message.isUser ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(message.text, style: const TextStyle(fontSize: 16.0)),
                ),
                if (message.suggestions != null && onSuggestionTap != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: message.suggestions!.map((suggestion) => ElevatedButton(
                        onPressed: () => onSuggestionTap!(suggestion),
                        child: Text(suggestion),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
              ],
            ),
          ),
          if (message.isUser)
            const SizedBox(width: 48), // Empty space to align with bot messages
        ],
      ),
    );
  }
}
