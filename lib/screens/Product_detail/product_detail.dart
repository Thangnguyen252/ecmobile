import 'package:ecmobile/models/cart_item_model.dart';
import 'package:ecmobile/models/customer_model.dart';
import 'package:ecmobile/screens/Order/checkout_page.dart';
import 'package:ecmobile/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// Đảm bảo import đúng đường dẫn AppColors của bạn
import 'package:ecmobile/theme/app_colors.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CustomerService _customerService = CustomerService();
  // --- STATE DỮ LIỆU ---
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _productData;

  // --- STATE GIAO DIỆN ---
  String? _selectedStorage; // Ví dụ: "256GB"
  String? _selectedColor;   // Ví dụ: "Titan Sa mạc"
  int _currentImageIndex = 0;
  int _quantity = 1; // Thêm biến số lượng

  // --- BIẾN DỮ LIỆU HIỂN THỊ ---
  List<dynamic> _rawVariants = []; // Lưu toàn bộ mảng variants từ API
  List<String> _availStorages = []; // Danh sách bộ nhớ có sẵn
  List<String> _availColors = [];   // Danh sách màu sắc có sẵn theo bộ nhớ
  List<String> _bannerImages = [];
  List<Map<String, dynamic>> _specs = [];
  List<Map<String, dynamic>> _colors = []; // Biến legacy, giữ lại để tránh lỗi logic cũ nếu có
  List<String> _featureHighlights = [];

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  // =======================================================
  // LOGIC FIREBASE
  // =======================================================
  Future<void> _fetchProductData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (!doc.exists) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Sản phẩm không tồn tại (ID: ${widget.productId})";
        });
        return;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // 1. Ảnh
      List<dynamic> rawImages = data['images'] ?? [];
      List<String> images = rawImages.map((e) => e.toString()).toList();
      if (images.isEmpty) images = ['https://via.placeholder.com/400x400?text=No+Image'];

      // 2. Mô tả (Feature Highlights)
      String desc = data['description'] ?? "";
      List<String> highlights = desc.split(RegExp(r'[.\n]')).where((e) => e.trim().isNotEmpty).toList();
      if (highlights.isEmpty) highlights = ["Hàng chính hãng", "Bảo hành 12 tháng"];

      // 3. Variants
      _processVariants(data['variants'] ?? []);

      // 4. Specs
      Map<String, dynamic> rawSpecs = data['specifications'] ?? {};
      List<Map<String, dynamic>> specs = _parseSpecifications(rawSpecs);

      setState(() {
        _productData = data;
        _bannerImages = images;
        _featureHighlights = highlights;
        _specs = specs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Lỗi tải dữ liệu: $e";
      });
    }
  }

  void _processVariants(List<dynamic> variants) {
    _rawVariants = variants;

    // 1. Lấy danh sách Storage duy nhất
    Set<String> storageSet = {};
    for (var v in variants) {
      var attr = v['attributes'] ?? {};
      if (attr.containsKey('storage')) {
        storageSet.add(attr['storage'].toString());  // ✅ Đơn giản: storage là string
      }
    }

    _availStorages = storageSet.toList();

    // 2. Sắp xếp theo thứ tự dung lượng (tùy chọn)
    _availStorages.sort((a, b) {
      int getSize(String s) {
        if (s.contains('GB')) return int.parse(s.replaceAll('GB', ''));
        if (s.contains('TB')) return int.parse(s.replaceAll('TB', '')) * 1024;
        return 0;
      }
      return getSize(a).compareTo(getSize(b));
    });

    // 3. Chọn mặc định cái đầu tiên
    if (_availStorages.isNotEmpty) {
      _selectedStorage = _availStorages[0];
      _updateAvailableColorsForStorage(_selectedStorage!);
    }
  }

  // SỬA LỖI 1: Đã xóa hàm trùng lặp, chỉ giữ lại 1 hàm duy nhất này
  // Hàm phụ trợ: Lọc ra các màu có sẵn cho Storage đang chọn
  void _updateAvailableColorsForStorage(String storage) {
    Set<String> colorSet = {};
    for (var v in _rawVariants) {
      var attr = v['attributes'] ?? {};
      // ✅ So sánh đơn giản: storage là string
      if (attr['storage'] == storage && attr.containsKey('color')) {
        colorSet.add(attr['color']);
      }
    }
    _availColors = colorSet.toList();

    // Chọn màu đầu tiên
    if (_availColors.isNotEmpty) {
      _selectedColor = _availColors[0];
    } else {
      _selectedColor = null;
    }
  }

  // Hàm phụ trợ: Lấy variant object cụ thể đang được chọn
  Map<String, dynamic>? _getSelectedVariant() {
    try {
      return _rawVariants.firstWhere((v) {
        var attr = v['attributes'] ?? {};
        // ✅ So sánh đơn giản: cả storage và color đều là string
        return attr['storage'] == _selectedStorage &&
            attr['color'] == _selectedColor;
      });
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> _parseSpecifications(Map<String, dynamic> specs) {
    final Map<String, String> dictionary = {
      'screen': 'Màn hình', 'resolution': 'Độ phân giải', 'cpu': 'Vi xử lý',
      'chip': 'Chipset', 'ram': 'RAM', 'storage': 'Bộ nhớ',
      'camera_rear': 'Cam sau', 'camera_front': 'Cam trước', 'battery': 'Pin',
      'os': 'Hệ điều hành', 'sim': 'Thẻ SIM', 'vga': 'Card đồ họa',
      'ssd': 'Ổ cứng', 'weight': 'Trọng lượng', 'refresh_rate': 'Tần số quét',
      'panel': 'Tấm nền', 'response_time': 'Phản hồi'
    };
    List<Map<String, dynamic>> result = [];
    specs.forEach((key, value) {
      String label = dictionary[key] ?? key.toUpperCase();
      result.add({'label': label, 'value': value.toString()});
    });
    return result;
  }

  Color _mapColorStringToColor(String colorName) {
    String lower = colorName.toLowerCase();
    if (lower.contains('đen') || lower.contains('black')) return Colors.black;
    if (lower.contains('trắng') || lower.contains('white')) return Colors.white;
    if (lower.contains('đỏ')) return Colors.red;
    if (lower.contains('xanh')) return Colors.blue;
    if (lower.contains('vàng')) return Colors.amber;
    if (lower.contains('bạc') || lower.contains('silver')) return Colors.grey.shade400;
    if (lower.contains('xám') || lower.contains('grey')) return Colors.grey.shade700;
    if (lower.contains('titan')) return const Color(0xFF8D8D8D);
    return Colors.grey;
  }

  String _formatCurrency(dynamic number) {
    if (number == null) return "Liên hệ";
    final formatter = NumberFormat("#,###", "vi_VN");
    return "${formatter.format(number)}₫";
  }

  // =======================================================
  // GIAO DIỆN (UI)
  // =======================================================
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.primary;
    final Color textRed = Colors.red;
    Map<String, dynamic>? currentVariant = _getSelectedVariant();
    if (_isLoading) {
      return Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: primaryColor)));
    }
    if (_productData == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(_errorMessage ?? "Lỗi")));
    }

    // 1. Lấy giá: Ưu tiên giá variant, nếu không có lấy giá gốc
    num currentPrice = currentVariant != null
        ? (currentVariant['price'] ?? _productData!['basePrice'])
        : (_productData!['basePrice'] ?? 0);
    num originalPrice = _productData!['originalPrice'] ?? 0;
    // Rating
    num ratingAverage = _productData!['ratingAverage'] ?? 0;
    num reviewCount = _productData!['reviewCount'] ?? 0;
    // 2. Lấy ảnh: Ưu tiên ảnh variant, nếu không có lấy ảnh bìa đầu tiên
    String displayImage = _bannerImages.isNotEmpty ? _bannerImages[0] : "";
    if (currentVariant != null) {
      var attr = currentVariant['attributes'];
      if (attr != null && attr['imageURL'] != null && attr['imageURL'].toString().isNotEmpty) {
        displayImage = attr['imageURL'];
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          _productData!['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: StreamBuilder<CustomerModel?>(
          stream: _customerService.getUserStream(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            final isFavorite = user?.favoriteProducts.contains(widget.productId) ?? false;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, color: Colors.grey),

                        // 1. BANNER TÍNH NĂNG
                        // SỬA LỖI 2: Đã khớp tham số truyền vào
                        _buildFeatureBanner(primaryColor, displayImage),

                        // 2. GIÁ & TÊN & ĐÁNH GIÁ
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Giá tiền (Ngang hàng)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatCurrency(currentPrice),
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                                  ),
                                  const SizedBox(width: 10),

                                  if (originalPrice > currentPrice)
                                    Transform.translate(
                                      offset: const Offset(0, -4),
                                      child: Text(
                                        _formatCurrency(originalPrice),
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Tên sản phẩm
                              Text(
                                _productData!['name'],
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 8),

                              // Rating & Yêu thích
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    if (index < ratingAverage.floor()) {
                                      return const Icon(Icons.star, color: Colors.amber, size: 18);
                                    } else if (index < ratingAverage) {
                                      return const Icon(Icons.star_half, color: Colors.amber, size: 18);
                                    }
                                    return const Icon(Icons.star_border, color: Colors.amber, size: 18);
                                  }),
                                  const SizedBox(width: 5),
                                  Text("($reviewCount)", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      if (user != null) {
                                        _customerService.toggleFavoriteProduct(widget.productId);
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                                            color: Colors.red, size: 20),
                                        const SizedBox(width: 4),
                                        Text(isFavorite ? "Đã thích" : "Yêu thích",
                                            style: const TextStyle(color: Colors.red, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 3. THẺ ƯU ĐÃI
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildOfferCard(primaryColor, textRed),
                        ),

                        const Divider(thickness: 4, color: Color(0xFFF5F5F5)),

                        // --- 4. PHIÊN BẢN (Variants) ---
                        if (_availStorages.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Chọn phiên bản", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: _availStorages.map((storage) {
                                    bool isSelected = _selectedStorage == storage;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedStorage = storage;
                                          _updateAvailableColorsForStorage(storage);
                                          _currentImageIndex = 0;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                              color: isSelected ? primaryColor : Colors.grey.shade300,
                                              width: isSelected ? 2 : 1
                                          ),
                                        ),
                                        child: Text(
                                          storage,
                                          style: TextStyle(
                                              color: isSelected ? primaryColor : Colors.black,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                        // --- 5. MÀU SẮC ---
                        if (_availColors.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Chọn màu sắc", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: _availColors.map((colorName) {
                                      bool isSelected = _selectedColor == colorName;

                                      // Tìm variant tương ứng
                                      var variantForThisColor = _rawVariants.firstWhere((v) {
                                        var attr = v['attributes'];
                                        // ✅ So sánh đơn giản
                                        return attr['storage'] == _selectedStorage &&
                                            attr['color'] == colorName;
                                      }, orElse: () => {});

                                      String variantImg = variantForThisColor['attributes']?['imageURL'] ?? _bannerImages[0];
                                      num variantPrice = variantForThisColor['price'] ?? 0;

                                      // ... phần còn lại giữ nguyên

                                      return GestureDetector(
                                        onTap: () => setState(() {
                                          _selectedColor = colorName;
                                          _currentImageIndex = 0;
                                        }),
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 12),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: isSelected ? primaryColor : Colors.grey.shade300,
                                                width: isSelected ? 2 : 1
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 35, height: 35,
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey.shade200),
                                                    borderRadius: BorderRadius.circular(4)
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(4),
                                                  child: Image.network(variantImg, fit: BoxFit.cover),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(colorName, style: TextStyle(
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                      fontSize: 12
                                                  )),
                                                  Text(_formatCurrency(variantPrice), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),
                        const Divider(thickness: 4, color: Color(0xFFF5F5F5)),

                        // 6. KHUYẾN MÃI & CAM KẾT
                        _buildPromotionsAndCommitment(primaryColor, textRed),

                        const Divider(thickness: 4, color: Color(0xFFF5F5F5)),

                        // 7. THÔNG SỐ KỸ THUẬT
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Thông số kỹ thuật",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200)),
                                child: Column(
                                  children: _specs
                                      .take(6)
                                      .map((spec) => _buildSpecItem(
                                      spec['label'], spec['value'], _specs.indexOf(spec) % 2 == 0))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey)),
                                  child: const Text("Xem cấu hình chi tiết",
                                      style: TextStyle(color: Colors.black)),
                                ),
                              )
                            ],
                          ),
                        ),

                        const Divider(thickness: 4, color: Color(0xFFF5F5F5)),

                        // 9. ĐÁNH GIÁ SẢN PHẨM
                        _buildProductRatingSection(primaryColor, ratingAverage, reviewCount),

                        const Divider(thickness: 4, color: Color(0xFFF5F5F5)),

                        // 10. HỎI & ĐÁP
                        _buildStaticSection(
                            "Hỏi & Đáp",
                            Column(
                              children: [
                                const TextField(
                                  decoration: InputDecoration(
                                    hintText: "Bạn có thắc mắc gì về sản phẩm?",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    suffixIcon: Icon(Icons.send, color: Colors.red),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _buildQAItem("Q: Sản phẩm này có hỗ trợ trả góp không?",
                                    "A: Dạ có ạ, bên em hỗ trợ trả góp 0% qua thẻ tín dụng."),
                                const SizedBox(height: 10),
                                _buildQAItem("Q: Bảo hành bao lâu?",
                                    "A: Sản phẩm bảo hành chính hãng 12 tháng tại các trung tâm bảo hành trên toàn quốc."),
                              ],
                            )),
                        const Divider(thickness: 4, color: Color(0xFFF5F5F5)),

                        // 11. TIN TỨC LIÊN QUAN
                        _buildStaticSection(
                            "Tin tức liên quan",
                            Column(
                              children: [
                                _buildNewsItem("assets/images/tintuclienquan2.jpg",
                                    "Đánh giá chi tiết hiệu năng sản phẩm: Quái vật cấu hình?"),
                                const SizedBox(height: 10),
                                _buildNewsItem("assets/images/tintuclienquan1.jpg",
                                    "So sánh với phiên bản tiền nhiệm: Có đáng nâng cấp?"),
                              ],
                            )),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // BOTTOM BAR
                _buildBottomBar(primaryColor),
              ],
            );
          }),
    );
  }

  // =======================================================
  // WIDGET HELPERS
  // =======================================================

  Widget _buildProductRatingSection(Color primaryColor, num rating, num count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đánh giá sản phẩm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Xem tất cả >',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        '/5',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      if (index < rating.floor()) return const Icon(Icons.star, color: Color(0xFFFFCC00), size: 24);
                      if (index < rating) return const Icon(Icons.star_half, color: Color(0xFFFFCC00), size: 24);
                      return const Icon(Icons.star_border, color: Color(0xFFFFCC00), size: 24);
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count lượt đánh giá',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),

              Container(
                height: 45,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: primaryColor,
                ),
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Viết đánh giá',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildRatingBar(5, count, (count * 0.7).toInt(), primaryColor),
          _buildRatingBar(4, count, (count * 0.2).toInt(), primaryColor),
          _buildRatingBar(3, count, (count * 0.1).toInt(), primaryColor),
          _buildRatingBar(2, count, 0, primaryColor),
          _buildRatingBar(1, count, 0, primaryColor),

          const SizedBox(height: 30),

          const Text(
            'Đánh giá theo trải nghiệm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _buildExperienceRating('Hiệu năng', '5.0/5', (count / 2).toInt()),
          _buildExperienceRating('Thời lượng pin', '4.8/5', (count / 2).toInt()),
          _buildExperienceRating('Chất lượng camera', '4.9/5', (count / 2).toInt()),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, num total, int count, Color color) {
    double percent = total == 0 ? 0 : (count / total);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$star', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey[200],
                color: color,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildExperienceRating(String label, String score, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Row(
            children: [
              Text(score, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 5),
              Text('($count)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOfferCard(Color primaryColor, Color textRed) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black, height: 1.4),
                    children: <TextSpan>[
                      const TextSpan(text: 'Tiết kiệm lên đến '),
                      TextSpan(
                        text: '230.000₫',
                        style: TextStyle(fontWeight: FontWeight.bold, color: textRed),
                      ),
                      const TextSpan(text: ' cho sinh viên UIT'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                    children: <TextSpan>[
                      const TextSpan(text: 'Ưu đãi cho Học sinh - sinh viên, Giảng viên - giáo viên đến '),
                      TextSpan(
                        text: '200.000₫',
                        style: TextStyle(fontWeight: FontWeight.bold, color: textRed),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kiểm tra giá cuối >',
                  style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsAndCommitment(Color primaryColor, Color textRed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPromotionSection(primaryColor, textRed),
          const SizedBox(height: 30),
          _buildCommitmentSection(primaryColor),
        ],
      ),
    );
  }

  Widget _buildPromotionSection(Color primaryColor, Color textRed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Khuyến mãi hấp dẫn", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFFFF4EB),
          ),
          child: Column(
            children: [
              _buildPromotionItem("1", "Giảm ngay 200.000đ khi thanh toán qua thẻ tín dụng"),
              _buildPromotionItem("2", "Tặng gói bảo hành vàng 12 tháng"),
              _buildPromotionItem("3", "Cơ hội trúng vàng SJC 9999 khi mua sắm"),
            ],
          ),
        ),
        const SizedBox(height: 15),
        const Text("Ưu đãi thêm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        _buildExtraOfferItem(Icons.card_membership, "Giảm thêm tới 1% cho thành viên Smember"),
        _buildExtraOfferItem(Icons.school, "Giảm thêm 5% cho Học sinh - Sinh viên"),
      ],
    );
  }

  Widget _buildCommitmentSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Cam kết sản phẩm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 15),
        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            _buildCommitmentItem(Icons.verified_user_outlined, "Bảo hành chính hãng 12 tháng"),
            _buildCommitmentItem(Icons.refresh, "Hư gì đổi nấy trong 30 ngày"),
            _buildCommitmentItem(Icons.monetization_on_outlined, "Hoàn tiền nếu không hài lòng"),
            _buildCommitmentItem(Icons.local_shipping_outlined, "Giao hàng nhanh toàn quốc"),
          ],
        ),
      ],
    );
  }

  Widget _buildCommitmentItem(IconData icon, String text) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 25,
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.3))),
        ],
      ),
    );
  }

  // SỬA LỖI 2 và 3: Thêm tham số displayImage vào hàm
  Widget _buildFeatureBanner(Color primaryColor, String displayImage) {
    Color gradientStart = const Color(0xFFFF9966);
    Color gradientEnd = const Color(0xFF80B3FF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradientStart, gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'TÍNH NĂNG NỔI BẬT',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _currentImageIndex == 0 ? displayImage : _bannerImages[_currentImageIndex],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_featureHighlights.isEmpty)
                                _buildFeatureItem("Thông tin sản phẩm đang cập nhật..."),
                              if (_featureHighlights.isNotEmpty)
                                ..._featureHighlights.take(3).map((text) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: _buildFeatureItem(text),
                                ))
                                    .toList(),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    _buildThumbnailGallery(primaryColor),
                  ],
                ),
              ),
              Positioned(
                right: 10,
                top: 105,
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _currentImageIndex = (_currentImageIndex + 1) % _bannerImages.length),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF666666)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailGallery(Color primaryColor) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _bannerImages.length,
        itemBuilder: (context, index) {
          bool isSelected = _currentImageIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _currentImageIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(_bannerImages[index], fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaticSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildQAItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.help_outline, size: 16, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(answer, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildNewsItem(String imagePath, String title) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 50,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.grey[200]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildPromotionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFFA661B), shape: BoxShape.circle),
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildExtraOfferItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value, bool isEven) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: isEven ? Colors.grey[50] : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
          Expanded(flex: 6, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          // Widget chọn số lượng
          Row(
            children: [
              _buildQuantityButton(Icons.remove, () {
                if (_quantity > 1) {
                  setState(() => _quantity--);
                }
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              _buildQuantityButton(Icons.add, () => setState(() => _quantity++)),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: primaryColor),
              child: TextButton(
                onPressed: () {
                  if (_productData != null) {
                    // SỬA LỖI 4: Tính toán lại giá và ảnh dựa trên variant đã chọn thay vì dùng index cũ
                    final productName = _productData!['name'] ?? 'Sản phẩm';

                    // Lấy variant hiện tại
                    Map<String, dynamic>? currentVariant = _getSelectedVariant();

                    // Lấy ảnh: ưu tiên ảnh variant, nếu không có thì lấy banner đầu tiên
                    String productImage = _bannerImages.isNotEmpty ? _bannerImages[0] : '';
                    if (currentVariant != null && currentVariant['attributes']?['imageURL'] != null) {
                      productImage = currentVariant['attributes']['imageURL'];
                    }

                    // Lấy giá: ưu tiên giá variant
                    final double currentPrice = currentVariant != null
                        ? (currentVariant['price'] ?? _productData!['basePrice']).toDouble()
                        : (_productData!['basePrice'] ?? 0).toDouble();

                    final double originalPrice =
                    (_productData!['originalPrice'] ?? currentPrice).toDouble();

                    // Tạo một CartItemModel
                    final item = CartItemModel(
                      cartItemId: '', // ID sẽ được tạo sau
                      productId: widget.productId,
                      productName: productName,
                      productImage: productImage,
                      currentPrice: currentPrice,
                      originalPrice: originalPrice,
                      quantity: _quantity,
                      promos: [], // Thêm promos nếu có
                    );

                    // Điều hướng đến trang checkout
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          itemsToCheckout: [item],
                        ),
                      ),
                    );
                  }
                },
                child: const Text('MUA NGAY', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: primaryColor, width: 1.5)),
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: primaryColor, size: 24),
              onPressed: () async {
                try {
                  await _customerService.addToCart(widget.productId, _quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm vào giỏ hàng!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}