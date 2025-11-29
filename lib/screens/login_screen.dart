// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/screens/register_screen.dart';
import 'package:ecmobile/screens/login_form_screen.dart';


// Giả sử đây là màn hình form nhập liệu bạn sẽ được chuyển đến// import 'package:ecmobile/screens/register_login_form_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để căn chỉnh
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Sử dụng Stack để chồng các lớp giao diện lên nhau
      body: Stack(
        children: [
          // Lớp 1: Nền màu cam phía trên
          Container(
            height: size.height,
            width: size.width,
            color: AppColors.primary,
          ),

          // Lớp 2: Phần màu trắng bo góc phía dưới
          Positioned(
            top: size.height * 0.35, // Bắt đầu ở khoảng 35% chiều cao màn hình
            child: Container(
              height: size.height * 0.65,
              width: size.width,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
            ),
          ),

          // Lớp 3: Toàn bộ nội dung (logo, text, nút bấm)
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  // Phần 1: Logo
                  SizedBox(height: size.height * 0.15),
                  const Text(
                    'Logo của DN',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: size.height * 0.18),

                  // Phần 2: Các nút bấm trong vùng màu trắng
                  // Nút Đăng nhập
                  _buildAuthButton(
                    text: 'Đăng nhập',
                    isPrimary: true,
                    onPressed: () {
                      print('Chuyển đến màn hình Đăng nhập');
                      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => RegisterLoginFormScreen()));
                    },
                  ),
                  const SizedBox(height: 20),
// Nút Đăng ký
                  _buildAuthButton(
                    text: 'Đăng ký',
                    isPrimary: false,
                    onPressed: () {
                      // Chuyển đến màn hình Đăng ký mới
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                  ),
//...
                  const Spacer(), // Đẩy các nút social xuống dưới cùng

                  // Phần 3: Đăng nhập với mạng xã hội
                  const Text(
                    'Hoặc đăng nhập với',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(assetPath: 'assets/images/google_logo.jpg'), // Bạn cần có ảnh này
                      const SizedBox(width: 30),
                      _buildSocialButton(assetPath: 'assets/images/facebook_logo.png'), // và ảnh này
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget private để xây dựng các nút Đăng nhập/Đăng ký cho gọn
  Widget _buildAuthButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 300,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : AppColors.white,
          foregroundColor: isPrimary ? AppColors.white : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          elevation: isPrimary ? 5 : 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget private để xây dựng nút social (Google, Facebook)
  Widget _buildSocialButton({required String assetPath}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: IconButton(
        icon: Image.asset(assetPath, height: 25),
        onPressed: () {
          print('Đăng nhập với ${assetPath.contains('google') ? 'Google' : 'Facebook'}');
        },
      ),
    );
  }
}
