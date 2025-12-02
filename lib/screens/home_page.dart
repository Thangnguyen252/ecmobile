import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecmobile/screens/login_screen.dart'; // Import màn hình đăng nhập

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- Hàm xử lý ĐĂNG XUẤT ---
  Future<void> _handleLogout() async {
    try {
      // 1. Đăng xuất khỏi Firebase Authentication
      await FirebaseAuth.instance.signOut();

      // 2. Điều hướng về màn hình đăng nhập (LoginScreen)
      //    và xóa toàn bộ stack điều hướng (pushAndRemoveUntil)
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false, // Xóa tất cả các route cũ
        );
      }
    } catch (e) {
      if (mounted) {
        // Hiển thị thông báo lỗi (nếu có)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng xuất: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Thêm Scaffold và AppBar để có chỗ đặt nút Đăng xuất
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trang Chủ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF6B21), // Sử dụng màu cam chủ đạo
        elevation: 0,
        actions: [
          // Nút Đăng xuất
          TextButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            label: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Đây là Nội dung Trang chủ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Xin chào, bạn đã đăng nhập thành công!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic test nút tìm kiếm
                print("Test nút...");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B21),
                foregroundColor: Colors.white,
              ),
              child: const Text('Test nút tìm kiếm'),
            )
          ],
        ),
      ),
    );
  }
}