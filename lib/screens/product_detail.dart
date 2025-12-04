import 'package:flutter/material.dart';

// Đây là StatefulWidget để quản lý trạng thái chọn màu sắc và phiên bản sản phẩm
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
  // Trạng thái quản lý lựa chọn
  int _selectedVersionIndex = 2;
  int _selectedColorIndex = 0;

  // THÊM: Biến trạng thái để quản lý ảnh chính đang hiển thị
  int _currentImageIndex = 0;

  // THÊM: Danh sách các URL ảnh để hiển thị trong banner
  final List<String> _bannerImages = [
    'https://picsum.photos/seed/oppoA58/100/140', // Ảnh 1 (mặc định)
    'https://picsum.photos/seed/mountain/100/140', // Ảnh 2
    'https://picsum.photos/seed/forest/100/140', // Ảnh 3
    'https://picsum.photos/seed/lake/100/140', // Ảnh 4
    'https://picsum.photos/seed/city/100/140', // Ảnh 5
  ];

  // Dữ liệu giả lập
  final List<String> _versions = ['X9 Pro\n16GB 512GB', 'X9 Pro\n16GB 512GB', 'X9\n12GB 256GB'];
  final List<Map<String, dynamic>> _colors = [
    {'name': 'Xám', 'price': '22.990.000₫', 'color': const Color(0xFFC0C0C0)},
    {'name': 'Đen', 'price': '22.990.000₫', 'color': Colors.black},
  ];

  // Dữ liệu Thông số kỹ thuật
  final List<Map<String, dynamic>> _specs = [
    {'label': 'Loại card đồ họa', 'value': 'AMD Radeon Graphics'},
    {'label': 'Dung lượng RAM', 'value': '16GB'},
    {'label': 'Loại RAM', 'value': 'DDR4'},
    {'label': 'Số khe RAM', 'value': '2 khe (8GB DDR4 Onboard + 8GB DDR4 SO-DIMM)'},
    {'label': 'Ổ cứng', 'value': '512GB M.2 NVMe PCIe 3.0 SSD'},
    {'label': 'Kích thước màn hình', 'value': '16 inches'},
    {'label': 'Công nghệ màn hình', 'value': 'Độ sáng 300nits\nĐộ phủ màu 45% NTSC\nMàn hình Chống chói\nTÜV Rheinland-certified'},
    {'label': 'Pin', 'value': '42WHrs, 3S1P, 3-cell Li-Ion'},
    {'label': 'Hệ điều hành', 'value': 'Windows 11 Home'},
    {'label': 'Độ phân giải màn hình', 'value': '1920 x 1200 pixels (WUXGA)'},
    {'label': 'Loại CPU', 'value': 'AMD Ryzen 7 7730U\n(2.0GHz, 8 lõi / 16 luồng, 16MB cache, up to 4.5 GHz max boost)'},
    {'label': 'Cổng kết nối', 'value': '1x USB 2.0 Type-A\n1x USB 3.2 Gen 1 Type-C (hỗ trợ truyền dữ liệu, sạc và DisplayPort™)'},
  ];

  // Dữ liệu Hỏi và Đáp giả lập
  final List<Map<String, dynamic>> _qna = [
    {
      'name': 'BBA Bùi Vạn Trường',
      'time': '1 giờ trước',
      'avatar': const Color(0xFF9CCC65),
      'question': 'iPhone 16 128gb lên đời bù bao nhiêu ạ',
      'reply_count': 1,
    },
    {
      'name': 'Nguyễn Hoàng Như Kha',
      'time': '7 giờ trước',
      'avatar': const Color(0xFFC49FDD),
      'question': 'Oppo find x9 có màu hồng không ạ',
      'reply_count': 3,
    },
    {
      'name': 'Thắng Alex',
      'time': '15 giờ trước',
      'avatar': const Color(0xFFEF9A9A),
      'question': 'Chào shop\nMk đang quan tâm đến oppo find x9 bản thường cho mk hỏi nếu ko lấy quà thì giá cũ thể là bao nhiêu vậy?',
      'reply_count': 1,
    },
  ];


  // =======================================================
  // HÀM BUILD CHÍNH
  // =======================================================
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFA661B); // Màu cam chủ đạo
    const textRed = Color(0xFFE53935); // Màu đỏ cho giá tiết kiệm

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Thông tin sản phẩm",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, size: 24), onPressed: () {}),
          _buildCartIcon(),
        ],
      ),
      // Đảm bảo SingleChildScrollView bọc toàn bộ nội dung body
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =======================================================
            // PHẦN 1: BANNER VÀ INFO (ĐÃ CHỈNH SỬA)
            // =======================================================
            _buildFeatureBanner(primaryColor),

            _buildProductInfoSection(primaryColor, textRed),

            // =======================================================
            // PHẦN 2: TÙY CHỌN & MÀU SẮC
            // =======================================================
            _buildSectionTitle("Tùy chọn"),
            _buildVersionOptions(primaryColor),
            _buildSectionTitle("Màu sắc"),
            _buildColorOptions(primaryColor),

            // =======================================================
            // PHẦN 3: KHUYẾN MÃI & CAM KẾT
            // =======================================================
            _buildPromotionsAndCommitment(primaryColor, textRed),

            // =======================================================
            // PHẦN 4: THÔNG SỐ KỸ THUẬT
            // =======================================================
            _buildSpecificationsTable(primaryColor),

            // =======================================================
            // PHẦN 5: ĐÁNH GIÁ SẢN PHẨM
            // =======================================================
            _buildProductRatingSection(primaryColor),

            // =======================================================
            // PHẦN 6: TIN TỨC LIÊN QUAN
            // =======================================================
            _buildRelatedNewsSection(primaryColor),

            // =======================================================
            // PHẦN 7: ĐẶT CÂU HỎI CHO CHÚNG TÔI
            // =======================================================
            _buildAskQuestionSection(primaryColor),

            // =======================================================
            // PHẦN 8: HỎI VÀ ĐÁP
            // =======================================================
            _buildQnASection(primaryColor),

            const SizedBox(height: 20),
          ],
        ),
      ),
      // =======================================================
      // PHẦN 9: BOTTOM NAVIGATION
      // =======================================================
      bottomNavigationBar: _buildBottomBar(primaryColor),
    );
  }

  // =======================================================
  // CÁC WIDGET CHỨC NĂNG VÀ LAYOUT
  // =======================================================

  // Icon giỏ hàng với Badge
  Widget _buildCartIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(icon: const Icon(Icons.shopping_cart_outlined, size: 24), onPressed: () {}),
        Positioned(
          right: 5,
          top: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: const Text(
              '51',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  // Header và Tiêu đề
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Banner Tính năng nổi bật (ĐÃ SỬA: Card effect, Bo góc, Chuyển ảnh)
  // Banner Tính năng nổi bật (ĐÃ SỬA: BỎ FIXED HEIGHT, TỰ ĐỘNG CO GỌN KHOẢNG CÁCH)
  Widget _buildFeatureBanner(Color primaryColor) {
    Color gradientStart = const Color(0xFFFF9966);
    Color gradientEnd = const Color(0xFF80B3FF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        // BỎ HEIGHT CỐ ĐỊNH (height: 330) -> Để Container tự co theo nội dung
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
              // Background Gradient và Nội dung (Tất cả gom vào 1 Column)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0), // Padding đều 4 cạnh
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradientStart, gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Quan trọng: Co chiều cao theo nội dung
                  children: [
                    const Text(
                      'TÍNH NĂNG NỔI BẬT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ảnh Sản phẩm Chính
                        Container(
                          width: 100,
                          height: 140,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _bannerImages[_currentImageIndex],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(child: Text("Ảnh SP", style: TextStyle(fontSize: 12, color: Colors.grey))),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeatureItem("Trang bị chip MediaTek Dimensity 9500 mạnh mẽ, RAM tối đa 16GB cho hiệu năng đa nhiệm mượt mà và ổn định."),
                              const SizedBox(height: 5),
                              _buildFeatureItem("Viên pin lớn 7025mAh hỗ trợ sạc nhanh SUPERVOOC™ 80W và sạc không dây AIRVOOC 50W siêu tốc."),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // --- KHOẢNG CÁCH GIỮA ẢNH CHÍNH VÀ ẢNH PHỤ ---
                    const SizedBox(height: 12), // Bạn chỉnh số này nhỏ lại nếu muốn gần hơn nữa

                    // --- DANH SÁCH ẢNH PHỤ (Đưa vào đây thay vì Positioned) ---
                    _buildThumbnailGallery(primaryColor),
                  ],
                ),
              ),

              // Nút chuyển slide (Arrow) - Giữ nguyên vị trí
              Positioned(
                right: 10,
                top: 105,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentImageIndex = (_currentImageIndex + 1) % _bannerImages.length;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
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

  // Widget Thumbnail ảnh/tính năng (KHÔNG CÒN DÙNG TRONG BANNER NỮA)
  Widget _buildThumbnail(IconData? icon, {String? url, required Color primaryColor, bool isSelected = false, double size = 60, double iconSize = 30, required Color boxColor}) {
    // Đã thay thế bằng _buildThumbnailGallery()
    return Container();
  }

  // HÀM GALLERY ĐÃ SỬA (Bỏ padding thừa để thẳng hàng với text bên trên)
  Widget _buildThumbnailGallery(Color primaryColor) {
    return Container(
      height: 50, // Chiều cao ảnh nhỏ
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // Bỏ padding: const EdgeInsets.symmetric(horizontal: 16) cũ vì Parent Column đã có padding rồi
        padding: EdgeInsets.zero,
        child: Row(
          children: _bannerImages.asMap().entries.map((entry) {
            int idx = entry.key;
            String imageUrl = entry.value;
            bool isSelected = idx == _currentImageIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentImageIndex = idx;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(right: 10), // Khoảng cách giữa các ảnh nhỏ
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 5)]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(child: Text("Ảnh", style: TextStyle(fontSize: 8, color: Colors.grey))),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Widget hiển thị từng gạch đầu dòng tính năng
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // Widget thông tin cơ bản và ưu đãi
  Widget _buildProductInfoSection(Color primaryColor, Color textRed) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "OPPO Find X9 12GB 256GB Chip media\nTek pin 7025A",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFCC00), size: 18),
                  const Text(" 5.0", style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 18, color: Colors.grey[300]),
                  const SizedBox(width: 8),
                  Text(
                    "Yêu thích",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Thẻ Ưu đãi
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildOfferCard(primaryColor, textRed),
        ),
      ],
    );
  }

  // Thẻ Ưu đãi
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

  // 3. Tùy chọn Phiên bản
  Widget _buildVersionOptions(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_versions.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedVersionIndex = index;
              });
            },
            child: _buildVersionChip(_versions[index], index, _selectedVersionIndex, primaryColor),
          );
        }),
      ),
    );
  }

  Widget _buildVersionChip(String label, int index, int selectedIndex, Color primaryColor) {
    bool isSelected = index == selectedIndex;

    return Container(
      width: 110,
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              color: isSelected ? primaryColor : Colors.black,
            ),
          ),
          if (isSelected)
            Positioned(
              top: -1,
              right: -1,
              child: CustomPaint(
                size: const Size(20, 20),
                painter: _CornerTrianglePainter(primaryColor: primaryColor),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 4. Màu sắc
  Widget _buildColorOptions(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: List.generate(_colors.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColorIndex = index;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(right: index == _colors.length - 1 ? 0 : 10.0),
              child: _buildColorItem(
                _colors[index]['name'],
                _colors[index]['price'],
                _colors[index]['color'],
                index == _selectedColorIndex,
                primaryColor,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildColorItem(String colorName, String price, Color color, bool isSelected, Color primaryColor) {
    return Container(
      width: 160,
      height: 60,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    colorName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? primaryColor : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                price,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          if (isSelected)
            Positioned(
              top: -1,
              right: -1,
              child: CustomPaint(
                size: const Size(20, 20),
                painter: _CornerTrianglePainter(primaryColor: primaryColor),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 5. Khuyến mãi và Cam kết
  Widget _buildPromotionsAndCommitment(Color primaryColor, Color textRed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PHẦN KHUYẾN MÃI HẤP DẪN ---
          _buildPromotionSection(primaryColor, textRed),

          const SizedBox(height: 30),

          // --- PHẦN CAM KẾT SẢN PHẨM ---
          _buildCommitmentSection(primaryColor),
        ],
      ),
    );
  }

  Widget _buildPromotionSection(Color primaryColor, Color textRed) {
    final promotionBoxColor = primaryColor.withOpacity(0.05);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: promotionBoxColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: primaryColor, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Khuyến mãi hấp dẫn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          _buildPromotionItem(
            1,
            'Danh sách cửa hàng trải nghiệm Find X9 Series',
            primaryColor,
            linkText: 'Xem chi tiết',
          ),
          _buildPromotionItem(
            2,
            'Tặng gói Google One Ai Premium miễn phí 3 tháng sử dụng',
            primaryColor,
          ),
          _buildPromotionItem(
            3,
            'Tặng data Viettel 5G 100GB/30 ngày cho khách hàng dùng sim Viettel',
            primaryColor,
          ),
          _buildPromotionItem(
            4,
            'Dịch vụ bảo hành Premium cho Find X9 series (24 tháng bảo hành, 12 tháng bảo hiểm rơi vỡ màn hình, Bảo hành tận nhà & bảo hành toàn cầu)',
            primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionItem(int number, String text, Color primaryColor, {String? linkText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 10, top: 2),
            child: Text(
              '$number',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(fontSize: 15, height: 1.3),
                ),
                if (linkText != null)
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      linkText,
                      style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitmentSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cam kết sản phẩm',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCommitmentItem(
              icon: Icons.card_giftcard,
              color: primaryColor,
              text: 'Mới, đầy đủ phụ kiện từ nhà sản xuất',
            ),
            const SizedBox(width: 10),
            _buildCommitmentItem(
              icon: Icons.flash_on,
              color: primaryColor,
              text: 'Điện thoại, cáp USB, sạc, que SIM, ốp lưng, hướng dẫn nhanh, hướng dẫn an toàn',
            ),
            const SizedBox(width: 10),
            _buildCommitmentItem(
              icon: Icons.shield_outlined,
              color: primaryColor,
              text: 'Bảo hành 24 tháng chính hãng.',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: const Text(
              '(liên hệ)',
              style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommitmentItem({required IconData icon, required Color color, required String text}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // 6. Thông số kỹ thuật
  Widget _buildSpecificationsTable(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề và nút Xem tất cả
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông số kỹ thuật',
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
          ),

          // Bảng Thông số kỹ thuật
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: _specs.map((spec) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cột trái: Label
                      SizedBox(
                        width: 120, // Chiều rộng cố định cho cột label
                        child: Text(
                          spec['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Cột phải: Value
                      Expanded(
                        child: Text(
                          spec['value'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 7. Phần Đánh giá sản phẩm
  Widget _buildProductRatingSection(Color primaryColor) {
    const totalRatings = 2;

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

          // --- TỔNG QUAN ĐÁNH GIÁ VÀ NÚT VIẾT ĐÁNH GIÁ ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '5.0',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        '/5',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFFFCC00), size: 24)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalRatings lượt đánh giá',
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

          // --- PROGRESS BARS ĐÁNH GIÁ CHI TIẾT ---
          _buildRatingBar(5, totalRatings, 2, primaryColor),
          _buildRatingBar(4, totalRatings, 0, primaryColor),
          _buildRatingBar(3, totalRatings, 0, primaryColor),
          _buildRatingBar(2, totalRatings, 0, primaryColor),
          _buildRatingBar(1, totalRatings, 0, primaryColor),

          const SizedBox(height: 30),

          // --- ĐÁNH GIÁ THEO TRẢI NGHIỆM ---
          const Text(
            'Đánh giá theo trải nghiệm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _buildExperienceRating('Hiệu năng', '5.0/5', 2),
          _buildExperienceRating('Thời lượng pin', '5.0/5', 2),
          _buildExperienceRating('Chất lượng camera', '5.0/5', 2),
        ],
      ),
    );
  }

  // Widget xây dựng từng dòng Đánh giá theo trải nghiệm
  Widget _buildExperienceRating(String label, String rating, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.grey[800], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Row(
                children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFFFCC00), size: 16)),
              ),
              const SizedBox(width: 8),
              Text(
                '$rating ($count đánh giá)',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget xây dựng thanh tiến trình đánh giá
  Widget _buildRatingBar(int star, int totalRatings, int count, Color primaryColor) {
    final double percentage = totalRatings > 0 ? count / totalRatings : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$star',
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          const Icon(Icons.star, color: Color(0xFFFFCC00), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 15),
          SizedBox(
            width: 70,
            child: Text(
              '$count đánh giá',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  // 8. Phần Tin tức liên quan (ĐÃ TỐI ƯU KHOẢNG CÁCH)
  Widget _buildRelatedNewsSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tin tức liên quan',
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
        ),

        // THAY ĐỔI 1: Giảm chiều cao ListView từ 200 xuống 170 để vừa vặn nội dung hơn
        SizedBox(
          height: 170,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              _buildNewsItem('Đánh giá iPhone 16 Pro Max ở năm 2025: Vẫn c...', 'https://picsum.photos/seed/news1/300/200'),
              _buildNewsItem('Cập nhật giá iPhone 20/10: Nhiều model giá...', 'https://picsum.photos/seed/news2/300/200'),
              _buildNewsItem('So sánh iPhone 17 vs 16 Pro Max: Nên mua iPho...', 'https://picsum.photos/seed/news3/300/200'),
              _buildNewsItem('So sánh iPhone 17 Pro Max và iPhone 16 Pro M...', 'https://picsum.photos/seed/news4/300/200'),
            ],
          ),
        ),

        // THAY ĐỔI 2: Xóa bỏ hoặc giảm SizedBox cuối cùng xuống còn 4.0
        const SizedBox(height: 4.0),
      ],
    );
  }

// Hàm phụ trợ: Widget cho từng mục tin tức
  Widget _buildNewsItem(String title, String imageUrl) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imageUrl,
              height: 100,
              width: 170,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                width: 170,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
          ),
        ],
      ),
    );
  }


// 9. Phần Đặt câu hỏi cho chúng tôi
  Widget _buildAskQuestionSection(Color primaryColor) {
    return Padding(
      // Padding ngang 16px. Padding dọc 0.0 vì khoảng cách đã được kiểm soát bởi SizedBox cha.
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hãy đặt câu hỏi cho chúng tôi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Tuyển đẹp trai sẽ phản hồi trong vòng 1 giờ. Nếu Quý khách gửi câu hỏi sau 22h, chúng tôi sẽ trả lời vào sáng hôm sau. Thông tin có thể thay đổi theo thời gian, vui lòng đặt câu hỏi để nhận được cập nhật mới nhất!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
            ),
            const SizedBox(height: 15.0),

            // Nút Gửi câu hỏi
            Container(
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: primaryColor,
              ),
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                label: const Text(
                  'Gửi câu hỏi',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


// 10. Phần Hỏi và đáp (ĐÃ ĐỒNG BỘ VIỀN VÀ KHỐI VỚI PHẦN TRÊN)
  Widget _buildQnASection(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0), // Bo góc 8.0 cho đồng bộ

          // --- THÊM VIỀN (STROKE) ---
          border: Border.all(
            color: Colors.grey.shade300, // Màu viền xám đậm hơn chút cho rõ nét
            width: 1.0,
          ),

          // --- HIỆU ỨNG NỔI KHỐI (SHADOW) ---
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Bóng nhẹ tạo độ nổi
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2), // Đổ bóng xuống dưới
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 15.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hỏi và đáp',
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
            ),

            // Danh sách câu hỏi
            ..._qna.map((q) => _buildQnAItem(q, primaryColor)).toList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

// Hàm phụ trợ: Widget cho từng mục Hỏi và Đáp
  Widget _buildQnAItem(Map<String, dynamic> qna, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: qna['avatar'] as Color,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  qna['name'].toString().substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              // Tên và Thời gian
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qna['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      qna['time'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Câu hỏi
          Text(
            qna['question'] as String,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 8),
          // Nút Phản hồi
          Row(
            children: [
              Icon(Icons.message_outlined, size: 16, color: primaryColor),
              const SizedBox(width: 5),
              Text(
                'Phản hồi',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 20),
              if (qna['reply_count'] > 0)
                Text(
                  'Xem tất cả ${qna['reply_count']} phản hồi',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              if (qna['reply_count'] > 0)
                Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 16),
            ],
          ),
        ],
      ),
    );
  }


  // 11. Thanh Bottom Navigation Bar
  Widget _buildBottomBar(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: primaryColor,
              ),
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'MUA NGAY',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryColor, width: 1.5),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: primaryColor, size: 24),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter cho hiệu ứng góc của chip được chọn
class _CornerTrianglePainter extends CustomPainter {
  final Color primaryColor;

  _CornerTrianglePainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = primaryColor;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// Custom Painter cho hiệu ứng góc của chip được chọn
