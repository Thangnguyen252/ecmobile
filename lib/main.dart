// lib/main.dart - PHIÊN BẢN CHỈ ĐỔI MÀU VIỀN, KHÔNG CÓ FIREBASE

import 'package:flutter/material.dart';
import 'package:ecmobile/screens/login_screen.dart';
import 'package:ecmobile/theme/app_colors.dart';   // Đảm bảo có dòng này
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//import 'package:ecmobile/utils/seed_laptop.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/layouts/main_layout.dart';
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

      // Sửa lại thuộc tính theme ở đây
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.white,
        primarySwatch: Colors.orange,

        // Phần quan trọng để đổi màu viền cam khi người dùng bấm vào TextField
        inputDecorationTheme: InputDecorationTheme(
          // Viền khi được CHỌN (focused)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
              color: AppColors.primary, // <-- Sử dụng màu cam của bạn
              width: 1.5,
            ),
          ),

          // Viền mặc định khi không được chọn
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),

          // Viền chung cho các trạng thái khác
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}