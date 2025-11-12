import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
// SỬA LẠI ĐƯỜNG DẪN: Thêm 'layouts/' và dùng 'package:'
import 'package:ecmobile/layouts/main_layout.dart';

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