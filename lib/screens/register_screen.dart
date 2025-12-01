// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:ecmobile/screens/otp_verify_screen.dart';
import 'package:ecmobile/services/email_auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController(); // Đổi từ Phone -> Email
  final TextEditingController _phoneController = TextEditingController(); // Vẫn giữ để nhập thông tin
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // --- LOGIC GỬI MÃ EMAIL ---
  Future<void> _handleRegister() async {
    // 1. Validate
    if (_emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showError('Email không hợp lệ');
      return;
    }

    if (_passwordController.text != _confirmPassController.text) {
      _showError('Mật khẩu nhập lại không khớp');
      return;
    }

    setState(() => _isLoading = true);

    // 2. Tạo mã OTP
    String otp = EmailAuthService.generateOTP();
    String email = _emailController.text.trim();
    String name = _nameController.text.trim();

    // 3. Gửi Email qua EmailJS
    bool isSent = await EmailAuthService.sendOTP(
      name: name,
      email: email,
      otp: otp,
    );

    setState(() => _isLoading = false);

    if (isSent) {
      // 4. Chuyển sang màn hình OTP (Mang theo OTP để so sánh)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerifyScreen(
            email: email,
            generatedOTP: otp, // Truyền mã vừa tạo sang để check
            userData: {
              "fullName": name,
              "email": email,
              "phoneNumber": _phoneController.text.trim(),
              "password": _passwordController.text,
            },
          ),
        ),
      );
    } else {
      _showError('Gửi mã thất bại. Vui lòng kiểm tra kết nối mạng hoặc thử lại.');
    }
  }

  void _showError(String content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Đăng ký tài khoản', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTextField(controller: _emailController, label: 'Email', hint: 'Nhập địa chỉ Email (Gmail)', icon: Icons.email),
            const SizedBox(height: 16),
            _buildTextField(controller: _phoneController, label: 'Số điện thoại', hint: 'Nhập SĐT liên hệ', icon: Icons.phone, isNumber: true),
            const SizedBox(height: 16),
            _buildTextField(controller: _nameController, label: 'Họ và tên', hint: 'Nhập họ tên', icon: Icons.person),
            const SizedBox(height: 16),
            _buildPassField(controller: _passwordController, label: 'Mật khẩu', isObscured: _isPasswordObscured, toggle: () => setState(() => _isPasswordObscured = !_isPasswordObscured)),
            const SizedBox(height: 16),
            _buildPassField(controller: _confirmPassController, label: 'Xác nhận mật khẩu', isObscured: _isConfirmPasswordObscured, toggle: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured)),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B21), // Cam
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Gửi mã xác nhận', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon, bool isNumber = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label *', style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: hint, filled: true, fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      )
    ]);
  }

  Widget _buildPassField({required TextEditingController controller, required String label, required bool isObscured, required VoidCallback toggle}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label *', style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: controller, obscureText: isObscured,
        decoration: InputDecoration(
          filled: true, fillColor: Colors.white,
          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility), onPressed: toggle),
        ),
      )
    ]);
  }
}