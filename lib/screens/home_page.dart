import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sản phẩm Firebase Demo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // 1. Điện thoại iPhone 17 Pro
            _buildProductButton(
              context,
              label: '📱 iPhone 17 Pro',
              color: Colors.black87,
              // ID này phải khớp chính xác với ID trong Firestore
              productId: 'ip17_pro',
            ),

            const SizedBox(height: 15),

            // 2. Tai nghe Sony
            _buildProductButton(
              context,
              label: '🎧 Sony WH-1000XM4',
              color: Colors.blueGrey,
              productId: 'audio_sony_xm4',
            ),

            const SizedBox(height: 15),

            // 3. Laptop (Dùng ID MSI bạn vừa thêm)
            _buildProductButton(
              context,
              label: '💻 Laptop MSI Stealth 18',
              color: Colors.deepPurple,
              productId: 'lt_msi_stealth18',
            ),

            const SizedBox(height: 15),

            // 4. Màn hình (Dùng ID Màn hình MSI bạn vừa thêm)
            _buildProductButton(
              context,
              label: '🖥️ Màn hình MSI G274F',
              color: Colors.red[800]!,
              productId: 'mon_msi_g274f',
            ),
          ],
        ),
      ),
    );
  }

  // Widget nút bấm custom
  Widget _buildProductButton(BuildContext context, {required String label, required Color color, required String productId}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        print("Đang mở sản phẩm ID: $productId"); // Log kiểm tra

        // Truyền ID sang main.dart thông qua arguments
        Navigator.of(context).pushNamed(
          '/product-detail',
          arguments: productId,
        );
      },
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}