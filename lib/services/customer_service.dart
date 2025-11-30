import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecmobile/models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ID cố định cho demo
  final String currentUserId = "user_thangvh2004";

  // Stream lắng nghe
  Stream<CustomerModel?> getUserStream() {
    return _db.collection('customers').doc(currentUserId).snapshots().map((doc) {
      if (doc.exists) {
        return CustomerModel.fromFirestore(doc);
      } else {
        return null;
      }
    });
  }

  // --- HÀM MỚI: Cập nhật thông tin khách hàng ---
  Future<void> updateCustomerInfo({
    required String fullName,
    required String nickname,
    required String email,
    required String phoneNumber,
    required String gender,
    required String address,
  }) async {
    try {
      await _db.collection('customers').doc(currentUserId).update({
        'fullName': fullName,
        'nickname': nickname,
        'email': email,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'address': address,
        // Có thể thêm field 'updatedAt': FieldValue.serverTimestamp()
      });
    } catch (e) {
      print("Lỗi cập nhật thông tin: $e");
      rethrow;
    }
  }
}