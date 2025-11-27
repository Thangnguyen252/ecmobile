import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- STATE QUẢN LÝ CHỈ SỐ TRANG ---
  int _currentImageIndex = 0;
  int _currentCategoryIndex = 0;

  // State cho các slider sản phẩm
  int _currentPhonePageIndex = 0;
  int _currentLaptopPageIndex = 0;
  int _currentAudioPageIndex = 0;
  int _currentMonitorPageIndex = 0;

  // --- [MỚI] STATE QUẢN LÝ TRANG YÊU THÍCH ---
  int _currentFavoritePageIndex = 0;

  // --- STATE QUẢN LÝ LỌC ---
  int _selectedPhoneChip = -1;
  int _selectedLaptopChip = -1;
  int _selectedAudioChip = -1;
  int _selectedMonitorChip = -1;

  // --- STATE QUẢN LÝ DANH SÁCH YÊU THÍCH ---
  List<Map<String, dynamic>> _favoriteProducts = [];

  // --- STREAMS ---
  late Stream<QuerySnapshot> _phoneStream;
  late Stream<QuerySnapshot> _laptopStream;
  late Stream<QuerySnapshot> _audioStream;
  late Stream<QuerySnapshot> _monitorStream;

  @override
  void initState() {
    super.initState();
    _phoneStream = _createStream(
        'cate_phone', _selectedPhoneChip, ['Apple', 'Samsung', 'Xiaomi', 'Vivo']);
    _laptopStream = _createStream('cate_laptop', _selectedLaptopChip,
        ['HP', 'Lenovo', 'Asus', 'Acer', 'MSI', 'Dell']);
    _audioStream = _createStream('cate_audio', _selectedAudioChip,
        ['Sony', 'JBL', 'Apple', 'Marshall']);
    _monitorStream = _createStream(
        'cate_monitor', _selectedMonitorChip, ['LG', 'Samsung', 'Asus', 'MSI']);
  }

  // --- HÀM XỬ LÝ YÊU THÍCH ---
  bool _isProductFavorite(String id) {
    return _favoriteProducts.any((item) => item['id'] == id);
  }

  void _toggleFavorite(Map<String, dynamic> productData) {
    setState(() {
      String id = productData['id'];
      if (_isProductFavorite(id)) {
        // Nếu đã thích thì xóa
        _favoriteProducts.removeWhere((item) => item['id'] == id);

        // Reset về trang 0 nếu xóa hết sản phẩm của trang hiện tại
        if (_favoriteProducts.isEmpty) {
          _currentFavoritePageIndex = 0;
        }
      } else {
        // Nếu chưa thích thì thêm vào
        _favoriteProducts.add(productData);
      }
    });
  }

  Stream<QuerySnapshot> _createStream(
      String categoryId, int selectedIndex, List<String> brands) {
    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('categoryId', isEqualTo: categoryId);

    if (selectedIndex != -1) {
      query = query.where('brand', isEqualTo: brands[selectedIndex]);
    }
    return query.snapshots();
  }

  // --- DỮ LIỆU TĨNH ---
  final List<String> imgList = [
    'https://i.ytimg.com/vi/3s49ddWEluo/maxresdefault.jpg',
    'http://i.ytimg.com/vi/3i1OB6wKYms/maxresdefault.jpg',
    'https://images.media-outreach.com/691777/image-1.png'
  ];

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

  List<List<dynamic>> _chunkList(List<dynamic> list, int chunkSize) {
    List<List<dynamic>> chunks = [];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán kích thước
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screenWidth - 32.0 - 16.0) / 2;
    double childAspectRatio = 0.48;
    double itemHeight = itemWidth / childAspectRatio;

    // sliderHeight: Chiều cao chuẩn cho Slider (gồm 2 hàng sản phẩm + khoảng cách)
    double sliderHeight = (itemHeight * 2) + 16.0 + 40.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopMenu(),
          _buildImageCarousel(),

          _buildSectionHeader(title: 'SẢN PHẨM NỔI BẬT', onSeeMore: () {}),
          _buildFilterChips(),

          // --- [ĐÃ SỬA] SECTION YÊU THÍCH DẠNG SLIDER ---
          _buildFavoriteSection(
              sliderHeight: sliderHeight,
              aspectRatio: childAspectRatio
          ),

          _buildAdBanner(
              'https://cdn.tgdd.vn/Products/Images/522/294104/Slider/ipad-pro-m2-11-inch638035032348738269.jpg'),
          _buildCategorySlider(),

          // 1. ĐIỆN THOẠI
          _buildFirebaseSection(
            title: 'ĐIỆN THOẠI',
            stream: _phoneStream,
            filterBrands: ['Apple', 'Samsung', 'Xiaomi', 'Vivo'],
            sliderHeight: sliderHeight,
            aspectRatio: childAspectRatio,
            selectedIndex: _selectedPhoneChip,
            pageIndex: _currentPhonePageIndex,
            onChipSelected: (index) {
              setState(() {
                if (_selectedPhoneChip == index) {
                  _selectedPhoneChip = -1;
                } else {
                  _selectedPhoneChip = index;
                }
                _currentPhonePageIndex = 0;
                _phoneStream = _createStream('cate_phone', _selectedPhoneChip,
                    ['Apple', 'Samsung', 'Xiaomi', 'Vivo']);
              });
            },
            onPageChanged: (index) {
              setState(() => _currentPhonePageIndex = index);
            },
          ),

          // 2. LAPTOP
          _buildFirebaseSection(
            title: 'LAPTOP',
            stream: _laptopStream,
            filterBrands: ['HP', 'Lenovo', 'Asus', 'Acer', 'MSI', 'Dell'],
            sliderHeight: sliderHeight,
            aspectRatio: childAspectRatio,
            selectedIndex: _selectedLaptopChip,
            pageIndex: _currentLaptopPageIndex,
            onChipSelected: (index) {
              setState(() {
                if (_selectedLaptopChip == index) {
                  _selectedLaptopChip = -1;
                } else {
                  _selectedLaptopChip = index;
                }
                _currentLaptopPageIndex = 0;
                _laptopStream = _createStream('cate_laptop', _selectedLaptopChip,
                    ['HP', 'Lenovo', 'Asus', 'Acer', 'MSI', 'Dell']);
              });
            },
            onPageChanged: (index) {
              setState(() => _currentLaptopPageIndex = index);
            },
          ),

          // 3. LOA / TAI NGHE
          _buildFirebaseSection(
            title: 'LOA / TAI NGHE',
            stream: _audioStream,
            filterBrands: ['Sony', 'JBL', 'Apple', 'Marshall'],
            sliderHeight: sliderHeight,
            aspectRatio: childAspectRatio,
            selectedIndex: _selectedAudioChip,
            pageIndex: _currentAudioPageIndex,
            onChipSelected: (index) {
              setState(() {
                if (_selectedAudioChip == index) {
                  _selectedAudioChip = -1;
                } else {
                  _selectedAudioChip = index;
                }
                _currentAudioPageIndex = 0;
                _audioStream = _createStream('cate_audio', _selectedAudioChip,
                    ['Sony', 'JBL', 'Apple', 'Marshall']);
              });
            },
            onPageChanged: (index) {
              setState(() => _currentAudioPageIndex = index);
            },
          ),

          // 4. MÀN HÌNH
          _buildFirebaseSection(
            title: 'MÀN HÌNH',
            stream: _monitorStream,
            filterBrands: ['LG', 'Samsung', 'Asus', 'MSI'],
            sliderHeight: sliderHeight,
            aspectRatio: childAspectRatio,
            selectedIndex: _selectedMonitorChip,
            pageIndex: _currentMonitorPageIndex,
            onChipSelected: (index) {
              setState(() {
                if (_selectedMonitorChip == index) {
                  _selectedMonitorChip = -1;
                } else {
                  _selectedMonitorChip = index;
                }
                _currentMonitorPageIndex = 0;
                _monitorStream = _createStream('cate_monitor', _selectedMonitorChip,
                    ['LG', 'Samsung', 'Asus', 'MSI']);
              });
            },
            onPageChanged: (index) {
              setState(() => _currentMonitorPageIndex = index);
            },
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- [ĐÃ CẬP NHẬT] WIDGET HIỂN THỊ YÊU THÍCH DẠNG SLIDER ---
  Widget _buildFavoriteSection({
    required double sliderHeight,
    required double aspectRatio,
  }) {
    // Nếu chưa có sản phẩm yêu thích thì ẩn đi
    if (_favoriteProducts.isEmpty) return SizedBox.shrink();

    // Chia danh sách yêu thích thành các trang (mỗi trang 4 sản phẩm)
    final favoritePages = _chunkList(_favoriteProducts, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Row(
            children: [
              Icon(Icons.favorite, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'SẢN PHẨM YÊU THÍCH',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),

        // Sử dụng CarouselSlider thay vì ListView
        CarouselSlider(
          options: CarouselOptions(
            initialPage: 0,
            height: sliderHeight, // Chiều cao đồng bộ, không lo RenderFlex overflow
            viewportFraction: 1.0,
            enableInfiniteScroll: false, // Không lặp vòng
            onPageChanged: (index, reason) {
              setState(() {
                _currentFavoritePageIndex = index;
              });
            },
          ),
          items: favoritePages.map((pageItems) {
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              physics: NeverScrollableScrollPhysics(), // Tắt cuộn của GridView
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: aspectRatio,
              ),
              itemCount: pageItems.length,
              itemBuilder: (context, index) {
                // Ép kiểu về Map<String, dynamic>
                final data = pageItems[index] as Map<String, dynamic>;
                return ProductCard(
                  data: data,
                  isFavorite: true,
                  onToggleFavorite: () => _toggleFavorite(data),
                );
              },
            );
          }).toList(),
        ),

        // Chỉ hiển thị dấu chấm nếu có nhiều hơn 1 trang
        if (favoritePages.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildScrollIndicator(
              currentIndex: _currentFavoritePageIndex,
              totalCount: favoritePages.length,
            ),
          ),

        Divider(thickness: 4, color: Colors.grey.shade100),
      ],
    );
  }

  // --- HÀM BUILD SECTION FIREBASE ---
  Widget _buildFirebaseSection({
    required String title,
    required Stream<QuerySnapshot> stream,
    required List<String> filterBrands,
    required double sliderHeight,
    required double aspectRatio,
    required int selectedIndex,
    required int pageIndex,
    required Function(int) onChipSelected,
    required Function(int) onPageChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: List.generate(filterBrands.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(filterBrands[index]),
                  selected: selectedIndex == index,
                  onSelected: (selected) => onChipSelected(index),
                  selectedColor: Colors.orange,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: selectedIndex == index ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: selectedIndex == index
                            ? Colors.orange
                            : Colors.grey.shade300,
                      )),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                  height: sliderHeight,
                  child: Center(child: CircularProgressIndicator()));
            }
            final products = snapshot.data!.docs;
            if (products.isEmpty)
              return Container(
                  height: 200, child: Center(child: Text("Chưa có sản phẩm nào")));

            final productPages = _chunkList(products, 4);

            return Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    initialPage: pageIndex,
                    height: sliderHeight,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) => onPageChanged(index),
                  ),
                  items: productPages.map((pageDocs) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: pageDocs.length,
                      itemBuilder: (context, index) {
                        // --- Lấy Data và ID ---
                        final doc = pageDocs[index] as QueryDocumentSnapshot;
                        final Map<String, dynamic> rawData =
                        doc.data() as Map<String, dynamic>;
                        final Map<String, dynamic> data = {
                          ...rawData,
                          'id': doc.id, // Gắn ID vào data để quản lý
                        };

                        return ProductCard(
                          data: data,
                          isFavorite: _isProductFavorite(data['id']),
                          onToggleFavorite: () => _toggleFavorite(data),
                        );
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                _buildScrollIndicator(
                  currentIndex: pageIndex,
                  totalCount: productPages.length,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // --- CÁC WIDGET PHỤ TRỢ (Indicators, Sliders...) ---

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
          width: isSelected ? 24.0 : 12.0,
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2.0),
          ),
        );
      }),
    );
  }

  Widget _buildScrollIndicator(
      {required int currentIndex, required int totalCount}) {
    if (totalCount <= 1) return SizedBox.shrink();
    const double indicatorWidth = 100.0;
    const double indicatorHeight = 4.0;
    return Center(
      child: Container(
        width: indicatorWidth,
        height: indicatorHeight,
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(indicatorHeight / 2)),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: (indicatorWidth / totalCount) * currentIndex,
              child: Container(
                width: indicatorWidth / totalCount,
                height: indicatorHeight,
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(indicatorHeight / 2)),
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
            initialPage: _currentImageIndex,
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
            initialPage: _currentCategoryIndex,
            height: 240.0,
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
                childAspectRatio: 0.7,
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
                          color: Colors.orange.shade700, size: 30),
                    ),
                    SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        category['title'],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
        SizedBox(height: 16.0),
        _buildScrollIndicator(
          currentIndex: _currentCategoryIndex,
          totalCount: categoryPages.length,
        ),
      ],
    );
  }

  Widget _buildTopMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
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
        Icon(icon, color: Colors.orange, size: 28),
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
              color: Colors.orange,
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
            onPressed: () {},
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
}

// --- PRODUCT CARD ---
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const ProductCard({
    Key? key,
    required this.data,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : super(key: key);

  String formatCurrency(num price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(price);
  }

  Widget _buildPromoTag(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: Colors.orange.shade200,
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

  @override
  Widget build(BuildContext context) {
    String name = data['name'] ?? 'Sản phẩm';
    num rawPrice = data['basePrice'] ?? 0;
    String imageUrl = 'https://via.placeholder.com/150';
    if (data['images'] != null && (data['images'] as List).isNotEmpty) {
      imageUrl = (data['images'] as List)[0];
    }
    String specs = data['description'] ?? '';
    num oldPrice = data['originalPrice'] ?? (rawPrice * 1.1);
    double rating = (data['ratingAverage'] is num)
        ? (data['ratingAverage'] as num).toDouble()
        : 4.5;

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
              offset: Offset(0, 3))
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
                  imageUrl,
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
                      borderRadius: BorderRadius.circular(4)),
                  child: Text('Trả góp 0%',
                      style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text('Giảm 10%',
                      style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
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
                  Flexible(
                    child: Text(name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.orange),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(height: 4),
                  Text(specs,
                      style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8),
                  Text(formatCurrency(rawPrice),
                      style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(formatCurrency(oldPrice),
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12)),
                  SizedBox(height: 8),
                  _buildPromoTag('Tặng gói Google AI 1 năm'),
                  _buildPromoTag('Trả góp 0% qua thẻ'),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(rating.toString(), style: TextStyle(fontSize: 12))
                      ]),
                      // --- NÚT TIM GỌI HÀM CALLBACK TỪ CHA ---
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        onPressed: onToggleFavorite,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
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
}