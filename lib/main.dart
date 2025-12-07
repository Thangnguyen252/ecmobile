import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//import 'package:ecmobile/utils/seed_laptop.dart';
import 'package:ecmobile/theme/app_colors.dart';
// SỬA LẠI ĐƯỜNG DẪN: Thêm 'layouts/' và dùng 'package:'
import 'package:ecmobile/layouts/main_layout.dart';
import 'package:ecmobile/screens/product_detail.dart'; // Tuấn mới thêm
// 1. IMPORT FILE MỚI
//import 'package:ecmobile/utils/seed_customer.dart';
// 1. QUAN TRỌNG: Import file chứa hàm nạp dữ liệu bạn vừa tạo
// (Đảm bảo bạn đã tạo file lib/utils/seed_data.dart và dán code tôi gửi ở tin nhắn trước)
//import 'package:ecmobile/utils/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Mua sắm',
      debugShowCheckedModeBanner: false,

      // KHỐI ROUTES ĐƯỢC THÊM VÀO ĐÂY
      routes: { // Tuấn mới thêm
        '/product-detail': (context) => const ProductDetailScreen(productId: 'temp_id'), // Tuấn mới thêm
      }, // Tuấn mới thêm

      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background, // Màu nền chung

        // SỬ DỤNG FONT MẶC ĐỊNH:
        // Xóa hoặc comment (thêm //) dòng này
        // fontFamily: 'Inter',

        // Tùy chỉnh theme để AppBar và BottomNav không bị màu lạ
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0, // Bỏ bóng đổ
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.white,
        ),
      ),
      home: const MainLayout(), // Bắt đầu với layout chính
    );
  }
}