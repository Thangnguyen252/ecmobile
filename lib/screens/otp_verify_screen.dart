// lib/screens/otp_verify_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecmobile/screens/register_success_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  final String generatedOTP; // Mã đúng do hệ thống tạo
  final Map<String, dynamic> userData;

  const OtpVerifyScreen({
    super.key,
    required this.email,
    required this.generatedOTP,
    required this.userData,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((e) => e.text).join();

  Future<void> _verifyOtp() async {
    String inputOtp = _otpCode;

    if (inputOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ 6 số')));
      return;
    }

    setState(() => _isLoading = true);

    if (inputOtp == widget.generatedOTP) {
      await _createFirebaseUser();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã xác nhận không đúng!')));
    }
  }

  Future<void> _createFirebaseUser() async {
    try {
      // 1. Tạo User Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.userData['password'],
      );

      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;

        // 2. Chuẩn bị dữ liệu Customer theo đúng mẫu bạn yêu cầu
        // Lưu ý: customerCode giả lập ngẫu nhiên, thực tế có thể cần logic sinh mã từ server
        String randomCode = "KH${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}";

        final customerData = {
          "uid": userId, // ID từ Auth
          "fullName": widget.userData['fullName'] ?? "Chưa cập nhật",
          "customerCode": randomCode, // VD: KH12345
          "nickname": widget.userData['fullName'], // Mặc định lấy tên thật làm nickname
          "email": widget.userData['email'],
          "phoneNumber": widget.userData['phoneNumber'] ?? "",
          "gender": "Nam", // Mặc định, user có thể sửa sau
          "address": "Hẻm 78 Tôn Thất Thuyết Phường 16 Quận 4", // Địa chỉ mẫu bạn yêu cầu

          // Mật khẩu (Lưu ý bảo mật: tốt nhất không nên lưu plain text nếu không cần thiết)
          "password": widget.userData['password'],

          // Logic hạng thành viên & chi tiêu khởi tạo
          "membershipRank": "Đồng", // Mới tạo thì nên là Đồng (hoặc Kim cương nếu bạn muốn hard-code test)
          "isStudent": false, // Mặc định false
          "studentRequestStatus": "pending", // Trạng thái yêu cầu HSSV
          "totalSpending": 0, // Chi tiêu ban đầu = 0
          "purchasedOrderCount": 0, // Số đơn hàng = 0

          "createdAt": FieldValue.serverTimestamp(), // Thời gian tạo (Timestamp)
        };

        // 3. Lưu vào Firestore - Collection 'customers'
        await FirebaseFirestore.instance
            .collection('customers') // Đã sửa từ 'users' thành 'customers'
            .doc(userId)
            .set(customerData);

        // 4. Thành công -> Chuyển màn hình
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const RegisterSuccessScreen()),
                (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String msg = 'Đăng ký thất bại';
      if (e.code == 'email-already-in-use') msg = 'Email này đã được sử dụng';
      if (e.code == 'weak-password') msg = 'Mật khẩu quá yếu';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      setState(() => _isLoading = false);
      print("Lỗi: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi hệ thống: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E9),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Xác thực Email', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Mã 6 số đã được gửi tới:', style: const TextStyle(color: Colors.grey)),
            Text(widget.email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) => SizedBox(
                width: 45, height: 50,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: "", filled: true, fillColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
                    if (val.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
                  },
                ),
              )),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B21)),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Xác nhận', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}