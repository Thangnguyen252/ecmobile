import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Hàm tạo đơn hàng mới lên Firestore
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      // Sử dụng orderId làm ID của document để dễ truy vấn
      String orderId = orderData['orderId'];

      await _db.collection('orders').doc(orderId).set(orderData);

      print("✅ Đã tạo đơn hàng thành công: $orderId");
    } catch (e) {
      print("❌ Lỗi khi tạo đơn hàng: $e");
      rethrow; // Ném lỗi để UI xử lý nếu cần
    }
  }
}