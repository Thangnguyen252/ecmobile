import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;

  const OrderDetailPage({Key? key, required this.orderData, required this.orderId}) : super(key: key);

  // --- 1. HÀM FORMAT TIỀN ---
  String formatCurrency(num price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(price);
  }

  // --- 2. HÀM FORMAT NGÀY ---
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
  }

  // --- 3. HÀM DỊCH TRẠNG THÁI ---
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'đã thanh toán':
      case 'completed':
        return Colors.green;
      case 'chờ xác nhận':
      case 'pending':
        return Colors.orange;
      case 'đang giao':
      case 'shipping':
        return Colors.blue;
      case 'đã hủy':
      case 'cancelled':
        return Colors.red;
      default: return Colors.grey;
    }
  }

  // --- 4. HÀM DỊCH PHƯƠNG THỨC THANH TOÁN ---
  String _getPaymentMethodText(int method) {
    switch (method) {
      case 1: return 'Thanh toán khi nhận hàng (COD)';
      case 2: return 'Chuyển khoản ngân hàng (VNPAY/QR)';
      case 3: return 'Ví điện tử (Momo/ZaloPay)';
      default: return 'Phương thức khác';
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = orderData['status'] ?? 'Đang xử lý';
    List<dynamic> items = orderData['items'] ?? [];
    String customerName = orderData['customerName'] ?? 'Khách hàng';
    String email = orderData['email'] ?? '';
    String address = orderData['shippingAddress'] ?? 'Chưa cập nhật địa chỉ';
    int paymentMethod = orderData['paymentMethod'] ?? 1;

    num totalAmount = orderData['totalAmount'] ?? 0;
    if (totalAmount == 0 && items.isNotEmpty) {
      for (var item in items) {
        totalAmount += (item['price'] ?? 0) * (item['quantity'] ?? 1);
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Thông tin đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            // --- KHỐI 1: TRẠNG THÁI & MÃ ĐƠN ---
            Container(
              width: double.infinity,
              color: Colors.white,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mã đơn hàng', style: TextStyle(color: Colors.grey[600])),
                      Text(orderId.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ngày đặt', style: TextStyle(color: Colors.grey[600])),
                      Text(formatDate(orderData['createdAt'])),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _getStatusColor(status).withOpacity(0.5))
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- KHỐI 2: ĐỊA CHỈ NHẬN HÀNG ---
            Container(
              margin: const EdgeInsets.only(top: 10),
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      const Text('Địa chỉ nhận hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(email, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(address, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),

            // --- KHỐI 3: DANH SÁCH SẢN PHẨM ---
            Container(
              margin: const EdgeInsets.only(top: 10),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 8),
                        const Text('Sản phẩm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final item = items[index] as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(4)
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  item['image'] ?? '',
                                  width: 70, height: 70, fit: BoxFit.cover,
                                  errorBuilder: (_,__,___) => Container(width: 70, height: 70, color: Colors.grey[100], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['productName'] ?? 'Sản phẩm',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('x${item['quantity'] ?? 1}', style: TextStyle(color: Colors.grey[600])),
                                      Text(
                                        formatCurrency(item['price'] ?? 0),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // --- KHỐI 4: THANH TOÁN (ĐÃ SỬA LỖI OVERFLOW) ---
            Container(
              margin: const EdgeInsets.only(top: 10),
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // [SỬA] Thay Row bằng Column để tránh tràn màn hình
                  const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    _getPaymentMethodText(paymentMethod),
                    style: const TextStyle(fontSize: 15),
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền hàng', style: TextStyle(color: Colors.grey)),
                      Text(formatCurrency(totalAmount)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Phí vận chuyển', style: TextStyle(color: Colors.grey)),
                      Text(formatCurrency(0)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Thành tiền', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        formatCurrency(totalAmount),
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}