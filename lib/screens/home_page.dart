import 'package:flutter/material.dart' hide CarouselController; // Giữ lại 'hide' để tránh lỗi
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dữ liệu giả lập cho carousel (ĐÃ CÓ)
  final List<String> imgList = [
    'https://i.ytimg.com/vi/3s49ddWEluo/maxresdefault.jpg',
    'http://i.ytimg.com/vi/3i1OB6wKYms/maxresdefault.jpg',
    'https://images.media-outreach.com/691777/image-1.png'
  ];

  // Dữ liệu giả lập cho lưới danh mục (ĐÃ CÓ)
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.tablet_mac, 'title': 'Tablet'},
    {'icon': Icons.phone_android, 'title': 'Điện thoại'},
    {'icon': Icons.laptop, 'title': 'Laptop'},
    {'icon': Icons.desktop_windows, 'title': 'Bộ PC'},
    {'icon': Icons.headphones, 'title': 'Tai nghe'},
    {'icon': Icons.monitor, 'title': 'Màn hình'},
    {'icon': Icons.tv, 'title': 'Tivi'},
    {'icon': Icons.memory, 'title': 'RAM'},
    {'icon': Icons.developer_board, 'title': 'VGA'},
    {'icon': Icons.memory_sharp, 'title': 'CPU'},
  ];

  // --- SỬA ĐỔI: Thêm 'brand' vào dữ liệu ---
  final List<Map<String, dynamic>> phoneProducts = [
    {
      'brand': 'Apple', // <-- THÊM MỚI
      'image': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-14-pro_2__5.png',
      'name': 'Iphone 14 Pro Max',
      'specs': '16GB | 512GB',
      'price': '30.999.000đ',
      'oldPrice': '33.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Samsung', // <-- THÊM MỚI
      'image': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-xanh_2_1_2_2.png', // Sửa link ảnh cho khác
      'name': 'Samsung Galaxy S23 Ultra',
      'specs': '16GB | 512GB',
      'price': '32.999.000đ',
      'oldPrice': '35.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Xiaomi', // <-- THÊM MỚI
      'image': 'https://cdn2.cellphones.com.vn/x/media/catalog/product/1/3/13_prooo_2_2.jpg', // Sửa link ảnh cho khác
      'name': 'Xiaomi 13 Pro',
      'specs': '16GB | 512GB',
      'price': '23.999.000đ',
      'oldPrice': '26.599.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Vivo', // <-- THÊM MỚI
      'image': 'https://cdn.mobilecity.vn/mobilecity-vn/images/2022/11/vivo-x90-pro-man-hinh-2k-minh-hoa-1.jpg', // Sửa link ảnh cho khác
      'name': 'Vivo X90 Pro 5G',
      'specs': '16GB | 512GB',
      'price': '16.950.000đ',
      'oldPrice': '18.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
  ];

  // --- SỬA ĐỔI: Đặt trạng thái ban đầu là -1 (không chọn) ---
  int _selectedPhoneChip = -1;

  @override
  Widget build(BuildContext context) {
    // Sử dụng SingleChildScrollView để cho phép cuộn
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Menu 4 biểu tượng ---
          _buildTopMenu(),

          // --- 2. Carousel quảng cáo (iPhone 17) ---
          _buildImageCarousel(),

          // --- 3. Tiêu đề "SẢN PHẨM NỔI BẬT" ---
          _buildSectionHeader(title: 'SẢN PHẨM NỔI BẬT', onSeeMore: () {}),

          // --- 4. Các chip lọc (Điện thoại, Laptop...) ---
          _buildFilterChips(),

          // --- 5. Banner quảng cáo (iPad Pro) ---
          _buildAdBanner(
              'https://cdn.tgdd.vn/Products/Images/522/294104/Slider/ipad-pro-m2-11-inch638035032348738269.jpg'),

          // --- 6. Lưới danh mục sản phẩm (Tablet, PC,...) ---
          _buildCategoryGrid(),

          // --- 7. Phần "ĐIỆN THOẠI" ---
          _buildPhoneSection(),
          // ---------------------------------

          // Thêm một chút khoảng trống ở dưới cùng
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // ... (Các hàm _buildTopMenu, _buildMenuItem, _buildImageCarousel, _buildSectionHeader, _buildFilterChips, _buildAdBanner, _buildCategoryGrid giữ nguyên) ...
  // ... (Bạn có thể dán chúng vào đây nếu muốn, tôi sẽ bỏ qua để cho gọn) ...
  // Widget trợ giúp cho Menu 4 biểu tượng
  Widget _buildTopMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuItem(Icons.diamond, 'Hạng thành viên'),
          _buildMenuItem(Icons.flash_on, 'Flash Sale'),
          _buildMenuItem(Icons.receipt_long, 'Lịch sử mua hàng'),
          _buildMenuItem(Icons.event_note, 'Sự kiện đặc biệt'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  // Widget trợ giúp cho Carousel hình ảnh
  Widget _buildImageCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 2.0,
        enlargeCenterPage: true,
      ),
      items: imgList
          .map((item) => Container(
        child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              child: Image.network(item,
                  fit: BoxFit.cover, width: 1000.0),
            )),
      ))
          .toList(),
    );
  }

  // Widget trợ giúp cho Tiêu đề các mục
  Widget _buildSectionHeader(
      {required String title, required VoidCallback onSeeMore}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onSeeMore,
            child: Text('Xem thêm >'),
          )
        ],
      ),
    );
  }

  // Widget trợ giúp cho các Chip lọc
  Widget _buildFilterChips() {
    final filters = ['Điện thoại', 'Laptop', 'Bộ PC', 'Linh kiện'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: filters
            .map((filter) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ActionChip(
            label: Text(filter),
            onPressed: () {
              // Xử lý logic lọc
            },
            backgroundColor: Colors.grey.shade200,
          ),
        ))
            .toList(),
      ),
    );
  }

  // Widget trợ giúp cho Banner quảng cáo
  Widget _buildAdBanner(String imageUrl) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }

  // Widget trợ giúp cho Lưới danh mục
  Widget _buildCategoryGrid() {
    return GridView.builder(
      // 2 dòng quan trọng để GridView hoạt động bên trong SingleChildScrollView
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),

      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 mục trên một hàng
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.8, // Điều chỉnh tỷ lệ để vừa vặn
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
              Icon(category['icon'], color: Colors.blue.shade700, size: 30),
            ),
            SizedBox(height: 8),
            Text(
              category['title'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
  // --- HÀM ĐÃ SỬA ĐỔI ---

  // 1. Widget chính cho toàn bộ khu vực "ĐIỆN THOẠI"
  Widget _buildPhoneSection() {
    // --- THÊM MỚI: Logic lọc ---
    final filters = ['Apple', 'Samsung', 'Xiaomi', 'Vivo']; // Danh sách bộ lọc
    List<Map<String, dynamic>> filteredProducts; // Danh sách sản phẩm đã lọc

    if (_selectedPhoneChip == -1) {
      // Nếu không có chip nào được chọn, hiển thị tất cả
      filteredProducts = phoneProducts;
    } else {
      // Nếu có chip được chọn, lọc danh sách
      String selectedBrand = filters[_selectedPhoneChip];
      filteredProducts = phoneProducts.where((product) {
        // So sánh trường 'brand' mới (không phân biệt hoa thường)
        return product['brand'].toLowerCase() == selectedBrand.toLowerCase();
      }).toList();
    }
    // ----------------------------

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Text(
            'ĐIỆN THOẠI',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Các chip lọc
        _buildPhoneFilterChips(), // Hàm này gọi danh sách chip đã sửa

        // Lưới sản phẩm
        GridView.builder(
          padding: const EdgeInsets.all(16.0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cột
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.6, // Điều chỉnh tỷ lệ này để vừa vặn
          ),
          // --- SỬA ĐỔI: Dùng danh sách đã lọc ---
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(filteredProducts[index]);
          },
          // ---------------------------------
        ),
      ],
    );
  }

  // 2. Widget cho các chip lọc (Apple, Samsung...)
  Widget _buildPhoneFilterChips() {
    // --- SỬA ĐỔI: Đổi 'OPPO' thành 'Vivo' để khớp dữ liệu ---
    final filters = ['Apple', 'Samsung', 'Xiaomi', 'Vivo'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: List.generate(filters.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: _selectedPhoneChip == index,
              onSelected: (selected) {
                setState(() {
                  // Logic này đã đúng: chọn thì gán index, bỏ chọn thì gán -1
                  _selectedPhoneChip = selected ? index : -1;
                });
              },
              selectedColor: Colors.blue.shade100,
              backgroundColor: Colors.grey.shade100,
              labelStyle: TextStyle(
                color: _selectedPhoneChip == index
                    ? Colors.blue.shade900
                    : Colors.black,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: _selectedPhoneChip == index
                        ? Colors.blue.shade100
                        : Colors.grey.shade300,
                  )),
            ),
          );
        }),
      ),
    );
  }

  // 3. Widget cho một thẻ SẢN PHẨM (Giữ nguyên)
  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh và các tag giảm giá
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                child: Image.network(
                  product['image'],
                  height: 150, // Đặt chiều cao cố định
                  width: double.infinity,
                  fit: BoxFit.contain, // Dùng 'contain' để thấy rõ sản phẩm
                  // Thêm loadingBuilder và errorBuilder để chuyên nghiệp hơn
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey.shade200,
                    child:
                    Icon(Icons.broken_image, color: Colors.grey.shade400),
                  ),
                ),
              ),
              // Tag Trả góp
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product['installment'],
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Tag Giảm giá
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product['discount'],
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Thông tin sản phẩm
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product['specs'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  product['price'],
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  product['oldPrice'],
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 8),
                // Các tag khuyến mãi (ví dụ)
                _buildPromoTag('Tặng gói Google AI 1 năm'),
                _buildPromoTag('Trả góp 0% qua thẻ'),
                SizedBox(height: 8),

                // Đánh giá và Yêu thích
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          product['rating'].toString(),
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Widget trợ giúp nhỏ cho các tag khuyến mãi (Giữ nguyên)
  Widget _buildPromoTag(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
      ),
    );
  }
}