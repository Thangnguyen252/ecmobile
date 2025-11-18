import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentImageIndex = 0;
  int _currentCategoryIndex = 0;

  final List<String> imgList = [
    'https://i.ytimg.com/vi/3s49ddWEluo/maxresdefault.jpg',
    'http://i.ytimg.com/vi/3i1OB6wKYms/maxresdefault.jpg',
    'https://images.media-outreach.com/691777/image-1.png'
  ];

  // Dữ liệu danh mục (Trang 1)
  final List<Map<String, dynamic>> categoryPageA = [
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

  // Dữ liệu danh mục (Trang 2)
  final List<Map<String, dynamic>> categoryPageB = [
    {'icon': Icons.mouse, 'title': 'Chuột'},
    {'icon': Icons.keyboard, 'title': 'Bàn phím'},
    {'icon': Icons.print, 'title': 'Máy in'},
    {'icon': Icons.router, 'title': 'Router'},
    {'icon': Icons.camera_alt, 'title': 'Camera'},
    {'icon': Icons.watch, 'title': 'Đồng hồ'},
    {'icon': Icons.speaker, 'title': 'Loa'},
    {'icon': Icons.battery_charging_full, 'title': 'Sạc dự phòng'},
    {'icon': Icons.usb, 'title': 'USB'},
    {'icon': Icons.cable, 'title': 'Cáp sạc'},
  ];

  List<List<Map<String, dynamic>>> get categoryPages =>
      [categoryPageA, categoryPageB];

  final List<Map<String, dynamic>> phoneProducts = [
    {
      'brand': 'Apple',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-14-pro_2__5.png',
      'name': 'Iphone 14 Pro Max',
      'specs': '16GB | 512GB',
      'price': '30.999.000đ',
      'oldPrice': '33.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Samsung',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-xanh_2_1_2_2.png',
      'name': 'Samsung Galaxy S23 Ultra',
      'specs': '16GB | 512GB',
      'price': '32.999.000đ',
      'oldPrice': '35.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Xiaomi',
      'image':
      'https://cdn2.cellphones.com.vn/x/media/catalog/product/1/3/13_prooo_2_2.jpg',
      'name': 'Xiaomi 13 Pro',
      'specs': '16GB | 512GB',
      'price': '23.999.000đ',
      'oldPrice': '26.599.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Vivo',
      'image':
      'https://cdn.mobilecity.vn/mobilecity-vn/images/2022/11/vivo-x90-pro-man-hinh-2k-minh-hoa-1.jpg',
      'name': 'Vivo X90 Pro 5G',
      'specs': '16GB | 512GB',
      'price': '16.950.000đ',
      'oldPrice': '18.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
  ];

  int _selectedPhoneChip = -1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopMenu(),

          // 1. SLIDER ẢNH (Giữ nguyên indicator dạng dấu gạch)
          _buildImageCarousel(),

          _buildSectionHeader(title: 'SẢN PHẨM NỔI BẬT', onSeeMore: () {}),
          _buildFilterChips(),
          _buildAdBanner(
              'https://cdn.tgdd.vn/Products/Images/522/294104/Slider/ipad-pro-m2-11-inch638035032348738269.jpg'),

          // 2. SLIDER DANH MỤC (Indicator dạng thanh thẳng + có khoảng cách)
          _buildCategorySlider(),

          _buildPhoneSection(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- LOẠI 1: INDICATOR DẠNG DẤU GẠCH (Cho Slider Ảnh) ---
  Widget _buildDashIndicator(
      {required int currentIndex, required int totalCount}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCount, (index) {
        bool isSelected = currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 4.0,
          width: isSelected ? 24.0 : 12.0, // Dài hơn khi active
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2.0),
          ),
        );
      }),
    );
  }

  // --- LOẠI 2: INDICATOR DẠNG THANH SCROLL (Cho Danh Mục) ---
  Widget _buildScrollIndicator(
      {required int currentIndex, required int totalCount}) {
    const double indicatorWidth = 100.0; // Chiều dài tổng của thanh
    const double indicatorHeight = 4.0;

    return Center(
      child: Container(
        width: indicatorWidth,
        height: indicatorHeight,
        decoration: BoxDecoration(
          color: Colors.grey.shade300, // Nền xám
          borderRadius: BorderRadius.circular(indicatorHeight / 2),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              // Tính vị trí trượt: (Tổng chiều dài / Số trang) * Trang hiện tại
              left: (indicatorWidth / totalCount) * currentIndex,
              child: Container(
                width: indicatorWidth / totalCount, // Chiều dài thanh cam
                height: indicatorHeight,
                decoration: BoxDecoration(
                  color: Colors.orange, // Màu cam
                  borderRadius: BorderRadius.circular(indicatorHeight / 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
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
        ),
        SizedBox(height: 10),
        // Dùng indicator dạng gạch ngang
        _buildDashIndicator(
          currentIndex: _currentImageIndex,
          totalCount: imgList.length,
        ),
      ],
    );
  }

  Widget _buildCategorySlider() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            autoPlay: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCategoryIndex = index;
              });
            },
          ),
          items: categoryPages.map((pageData) {
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: pageData.length,
              itemBuilder: (context, index) {
                final category = pageData[index];
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(category['icon'],
                          color: Colors.blue.shade700, size: 30),
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
          }).toList(),
        ),
        // --- THÊM KHOẢNG CÁCH Ở ĐÂY ---
        SizedBox(height: 12.0), // Cách ra một chút
        // Dùng indicator dạng thanh scroll
        _buildScrollIndicator(
          currentIndex: _currentCategoryIndex,
          totalCount: categoryPages.length,
        ),
      ],
    );
  }

  // ... (Các widget khác giữ nguyên) ...
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

  Widget _buildAdBanner(String imageUrl) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildPhoneSection() {
    final filters = ['Apple', 'Samsung', 'Xiaomi', 'Vivo'];
    List<Map<String, dynamic>> filteredProducts;

    if (_selectedPhoneChip == -1) {
      filteredProducts = phoneProducts;
    } else {
      String selectedBrand = filters[_selectedPhoneChip];
      filteredProducts = phoneProducts.where((product) {
        return product['brand'].toLowerCase() == selectedBrand.toLowerCase();
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        _buildPhoneFilterChips(),
        GridView.builder(
          padding: const EdgeInsets.all(16.0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            // Giữ fix overflow ở đây (0.53)
            childAspectRatio: 0.53,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(filteredProducts[index]);
          },
        ),
      ],
    );
  }

  Widget _buildPhoneFilterChips() {
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                child: Image.network(
                  product['image'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey.shade200,
                    child:
                    Icon(Icons.broken_image, color: Colors.grey.shade400),
                  ),
                ),
              ),
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
          Expanded(
            child: Padding(
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
                  _buildPromoTag('Tặng gói Google AI 1 năm'),
                  _buildPromoTag('Trả góp 0% qua thẻ'),
                  Spacer(),
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
          ),
        ],
      ),
    );
  }

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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}