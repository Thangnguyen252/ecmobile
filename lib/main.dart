// lib/main.dart — PHIÊN BẢN CÓ FIREBASE + GIỮ NGUYÊN ĐỔI MÀU VIỀN TEXTFIELD

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File này sinh ra bởi lệnh flutterfire configure

import 'package:ecmobile/screens/login_screen.dart';
import 'package:ecmobile/theme/app_colors.dart';

Future<void> main() async {
  // Bắt buộc khi dùng async trong main
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECMobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.white,
        primarySwatch: Colors.orange,

        // Giữ nguyên cấu hình thay đổi màu viền TextField
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
