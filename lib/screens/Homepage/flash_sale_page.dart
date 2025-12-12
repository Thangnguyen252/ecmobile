import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FlashSalePage extends StatefulWidget {
  const FlashSalePage({Key? key}) : super(key: key);

  @override
  State<FlashSalePage> createState() => _FlashSalePageState();
}

class _FlashSalePageState extends State<FlashSalePage> {
  late DateTime endTime;
  late Timer _timer;
  Duration _timeLeft = Duration();

  // Cho phép null (?) để tránh lỗi LateInitializationError khi Hot Reload
  Stream<QuerySnapshot>? _productsStream;

  @override
  void initState() {
    super.initState();

    // Khởi tạo Stream
    _productsStream = FirebaseFirestore.instance.collection('products').limit(20).snapshots();

    // Cài đặt thời gian đếm ngược (2 tiếng)
    endTime = DateTime.now().add(const Duration(hours: 2));
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeLeft = endTime.difference(DateTime.now());
          if (_timeLeft.isNegative) {
            _timer.cancel();
            _timeLeft = Duration.zero;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours : $minutes : $seconds";
  }

  String formatCurrency(num price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flash Sale", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- HEADER ĐẾM NGƯỢC ---
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "KẾT THÚC TRONG",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatDuration(_timeLeft),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- DANH SÁCH SẢN PHẨM ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Thêm '?? ...' để nếu _productsStream bị null (do reload) thì tạo mới ngay lập tức
              stream: _productsStream ?? FirebaseFirestore.instance.collection('products').limit(20).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs;

                if (products.isEmpty) {
                  return const Center(child: Text("Hiện chưa có sản phẩm Flash Sale nào"));
                }

                return ListView.builder(
                  key: const PageStorageKey('flash_sale_list'),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final doc = products[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // Trích xuất dữ liệu cơ bản
                    String name = data['name'] ?? 'Sản phẩm';
                    num price = data['basePrice'] ?? 0;
                    num originalPrice = data['originalPrice'] ?? (price * 1.2);

                    String imageUrl = 'https://via.placeholder.com/150';
                    if (data['images'] != null && (data['images'] as List).isNotEmpty) {
                      imageUrl = (data['images'] as List)[0];
                    }

                    int discountPercent = 0;
                    if (originalPrice > price) {
                      discountPercent = ((originalPrice - price) / originalPrice * 100).round();
                    }

                    // Logic tính toán thanh tiến trình
                    int sold = data['sold'] ?? 0;
                    int totalStock = data['stock'] ?? 50;

                    // Tính phần trăm để hiển thị thanh màu
                    double progress = 0.0;
                    if (totalStock > 0) {
                      progress = (sold / totalStock).clamp(0.0, 1.0);
                    }

                    // --- [CODE ĐÃ SỬA: THÊM HIỆU ỨNG INKWELL] ---
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      elevation: 2,
                      // 1. Thêm clipBehavior để cắt hiệu ứng gợn sóng theo hình bo tròn
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      // 2. Bọc nội dung trong InkWell
                      child: InkWell(
                        onTap: () {
                          // TODO: Chuyển sang trang chi tiết sản phẩm
                          print("Đã bấm vào: $name");
                        },
                        splashColor: Colors.orange.withOpacity(0.2), // Màu gợn sóng cam
                        highlightColor: Colors.orange.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          formatCurrency(price),
                                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        if (discountPercent > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Giảm $discountPercent%',
                                              style: const TextStyle(color: Colors.deepOrange, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (originalPrice > price)
                                      Text(
                                        formatCurrency(originalPrice),
                                        style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 12),
                                      ),
                                    const SizedBox(height: 12),

                                    // UI thanh trạng thái đã bán
                                    LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Stack(
                                            children: [
                                              // Thanh nền xám (tổng kho)
                                              Container(
                                                height: 16,
                                                width: constraints.maxWidth,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              // Thanh màu gradient (số đã bán)
                                              if (sold > 0)
                                                Container(
                                                  height: 16,
                                                  width: constraints.maxWidth * progress,
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              // Chữ hiển thị
                                              Center(
                                                child: Text(
                                                  sold > 0 ? "Đã bán $sold" : "Vừa mở bán",
                                                  style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}