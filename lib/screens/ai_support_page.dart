import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/chat_model.dart';
import 'chat_detail_page.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/widgets/custom_search_app_bar.dart'; // Import widget Search Bar tùy chỉnh
import 'package:ecmobile/screens/cart_page.dart'; // Import trang giỏ hàng để điều hướng

class AiSupportPage extends StatefulWidget {
  const AiSupportPage({Key? key}) : super(key: key);

  @override
  State<AiSupportPage> createState() => _AiSupportPageState();
}

class _AiSupportPageState extends State<AiSupportPage> {
  // Giả sử userId của người đang đăng nhập.
  final String currentUserId = "user_thangvh2004";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- CONTROLLERS CHO CUSTOM APP BAR ---
  final TextEditingController _searchController = TextEditingController();
  final int _cartItemCount = 5; // Số lượng giả định trong giỏ hàng

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCart() {
    // Điều hướng đến trang giỏ hàng khi nhấn icon giỏ hàng
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartPage()),
    );
  }
  // -------------------------------------

  void _createNewSession() async {
    String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    String timeNow = DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now());

    ChatSession newSession = ChatSession(
      sessionId: sessionId,
      sessionName: "Cuộc trò chuyện mới",
      customerName: "Nguyễn Quang Thắng",
      userId: currentUserId,
      lastUpdated: timeNow,
      messages: [
        ChatMessage(
            content: "Chào bạn! 👋 Tôi là Trợ lý Ảo của app. Tôi ở đây để giúp bạn tìm ra những sản phẩm phù hợp nhất.",
            role: "ai",
            timestamp: timeNow
        )
      ],
    );

    await _firestore.collection('chat_sessions').doc(sessionId).set(newSession.toJson());

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDetailPage(session: newSession)),
    );
  }

  void _deleteSession(String sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa cuộc trò chuyện?"),
        content: const Text("Bạn có chắc chắn muốn xóa lịch sử này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              _firestore.collection('chat_sessions').doc(sessionId).delete();
              Navigator.pop(context);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editSessionName(String sessionId, String currentName) {
    TextEditingController nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đổi tên cuộc trò chuyện"),
        content: TextField(controller: nameController, decoration: const InputDecoration(hintText: "Nhập tên mới")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _firestore.collection('chat_sessions').doc(sessionId).update({'sessionName': nameController.text});
              }
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // --- SỬ DỤNG CUSTOM SEARCH APP BAR ---
      appBar: CustomSearchAppBar(
        searchController: _searchController,
        cartItemCount: _cartItemCount,
        onCartPressed: _navigateToCart,
        showBackButton: false, // Ẩn nút back vì đây là trang chính trên tab bar (nếu cần)
      ),
      // ------------------------------------

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chat_sessions')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("Chưa có cuộc trò chuyện nào"),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              ChatSession session = ChatSession.fromSnapshot(docs[index]);

              return Card(
                color: Colors.white,
                elevation: 2,

                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatDetailPage(session: session)),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // --- THAY ĐỔI AVATAR THÀNH ẢNH ASSET ---
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('assets/images/ai_avatar.jpg'),
                          backgroundColor: Colors.transparent, // Đặt nền trong suốt để tránh viền nếu ảnh PNG
                        ),
                        // ---------------------------------------
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.sessionName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${session.lastUpdated}",
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () => _editSessionName(session.sessionId, session.sessionName),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => _deleteSession(session.sessionId),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewSession,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}