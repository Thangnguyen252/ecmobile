import 'package:flutter/material.dart';
// HomePage KHÔNG cần import AppBar hoặc CartPage nữa

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // HomePage KHÔNG cần quản lý controller hoặc cart item nữa
  // vì MainLayout đã làm việc đó.

  @override
  Widget build(BuildContext context) {
    // --- LỖI NẰM Ở ĐÂY ---
    // Đã XÓA Scaffold và AppBar
    // HomePage chỉ là phần nội dung (body)
    // ---------------------
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Đây là Nội dung Trang chủ',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Logic test nút tìm kiếm
              // (Sau này bạn sẽ cần truy cập controller từ MainLayout
              // thông qua state management như Provider/Riverpod)
              print("Test nút...");
            },
            child: const Text('Test nút tìm kiếm'),
          ),

          const SizedBox(height: 10), // Tuấn vừa thêm
          ElevatedButton( // Tuấn vừa thêm
            onPressed: () { // Tuấn vừa thêm
              // Điều hướng đến trang chi tiết sản phẩm đã định nghĩa trong main.dart // Tuấn vừa thêm
              Navigator.of(context).pushNamed( // Tuấn vừa thêm
                '/product-detail', // Tuấn vừa thêm
                arguments: 'test_product_id', // Tuấn vừa thêm
              ); // Tuấn vừa thêm
            }, // Tuấn vừa thêm
            child: const Text('Test thông tin chi tiết sản phẩm'), // Tuấn vừa thêm
          ) // Tuấn vừa thêm
        ],
      ),
    );
  }
}