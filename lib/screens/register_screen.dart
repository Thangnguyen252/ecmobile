// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Biến để quản lý trạng thái ẩn/hiện của mật khẩu
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thêm một màu nền nhẹ cho toàn bộ màn hình
      backgroundColor: const Color(0xFFFFF3E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Đăng ký tài khoản',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Trường Số điện thoại
              _buildTextField(label: 'Số điện thoại', hint: 'Nhập số điện thoại', isRequired: true),
              const SizedBox(height: 20),

              // Trường Tên tài khoản
              _buildTextField(label: 'Tên tài khoản', hint: 'Nhập tên tài khoản mới'),
              const SizedBox(height: 20),

              // Trường Mật khẩu
              _buildPasswordField(
                label: 'Mật khẩu',
                hint: 'Tạo mật khẩu mới',
                isObscured: _isPasswordObscured,
                onToggle: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Trường Xác nhận mật khẩu
              _buildPasswordField(
                label: 'Xác nhận mật khẩu',
                hint: 'Nhập lại mật khẩu',
                isObscured: _isConfirmPasswordObscured,
                onToggle: () {
                  setState(() {
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                  });
                },
              ),
              const SizedBox(height: 40),

              // Nút Đăng ký
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Thêm logic xử lý đăng ký ở đây
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Phần "Hoặc" và social login
              const Center(child: Text('Hoặc', style: TextStyle(color: Colors.grey))),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(assetPath: 'assets/images/google_logo.jpg'),
                  const SizedBox(width: 30),
                  _buildSocialButton(assetPath: 'assets/images/facebook_logo.png'),
                ],
              ),
              const SizedBox(height: 30),

              // Link quay lại Đăng nhập
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Quay lại màn hình trước đó
                    Navigator.of(context).pop();
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Bạn đã có tài khoản? ',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Đăng nhập ngay',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget con để xây dựng các trường nhập liệu thông thường
  Widget _buildTextField({required String label, required String hint, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  // Widget con để xây dựng các trường nhập mật khẩu
  Widget _buildPasswordField({
    required String label,
    required String hint,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: isObscured,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscured ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  // Widget con để xây dựng nút social (tái sử dụng từ màn hình trước)
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
        onPressed: () {},
      ),
    );
  }
}
