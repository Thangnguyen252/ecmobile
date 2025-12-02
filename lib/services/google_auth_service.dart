// lib/services/google_auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecmobile/screens/home_page.dart';
import 'package:google_sign_in/google_sign_in.dart';


class GoogleAuthService {
  // 1. Khởi tạo Firebase Auth
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 2. Khởi tạo GoogleSignIn
  // Lưu ý: Đảm bảo class GoogleSignIn được import từ package:google_sign_in/google_sign_in.dart
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Hàm Đăng nhập
  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // 3. Kích hoạt luồng đăng nhập Google (Mở popup chọn tài khoản)
      // Lỗi "undefined method signIn" sẽ hết nếu import đúng
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Nếu người dùng bấm hủy, thoát hàm
      if (googleUser == null) return;

      // 4. Lấy thông tin xác thực (Token) từ Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 5. Tạo credential để đăng nhập vào Firebase
      // Lỗi "undefined getter accessToken" sẽ hết nếu import đúng
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 6. Đăng nhập vào Firebase bằng credential trên
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // 7. Kiểm tra xem user này đã tồn tại trong Firestore chưa
        final userDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // 8. Nếu là user mới -> Tạo dữ liệu trong Firestore
          String randomCode = "KH${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}";

          final customerData = {
            "uid": user.uid,
            "fullName": user.displayName ?? "Người dùng Google",
            "customerCode": randomCode,
            "nickname": user.displayName,
            "email": user.email,
            "phoneNumber": user.phoneNumber ?? "",
            "gender": "Nam", // Giá trị mặc định
            "address": "Chưa cập nhật",
            "photoUrl": user.photoURL,
            "authMethod": "google", // Đánh dấu nguồn gốc

            "membershipRank": "Đồng",
            "isStudent": false,
            "studentRequestStatus": "pending",
            "totalSpending": 0,
            "purchasedOrderCount": 0,
            "createdAt": FieldValue.serverTimestamp(),
          };

          await FirebaseFirestore.instance
              .collection('customers')
              .doc(user.uid)
              .set(customerData);
        }

        // 9. Đăng nhập thành công -> Chuyển về Home
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập Google thành công!')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      print("Lỗi Google Sign In: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thất bại: $e')),
        );
      }
    }
  }

  // Hàm Đăng xuất
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}