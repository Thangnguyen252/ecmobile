import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductListPage extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final List<String>? brands;

  const ProductListPage({
    Key? key,
    required this.categoryId,
    required this.categoryTitle,
    this.brands,
  }) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final Color primaryColor = const Color(0xFFFA661B);

  // Filter states
  String _selectedBrand = '';
  String _sortBy = 'popular';

  // [MỚI] State lọc giá
  double? _minPrice;
  double? _maxPrice;
  int _selectedPriceRangeIndex = -1;

  // Banner state
  int _currentBannerIndex = 0;

  // Stream dữ liệu
  late Stream<QuerySnapshot> _productStream;

  // Dữ liệu banner
  final List<String> bannerImages = [
    'https://dlcdnwebimgs.asus.com/gain/97BA7948-D027-4342-896E-5D2456336FD0',
    'https://vn.store.asus.com/media/wysiwyg/roglaptop/laptop-gaming-asus-2023-header-desktop.png',
    'https://dlcdnwebimgs.asus.com/gain/4308708A-A781-4F7E-A1E4-9DD438ABCA4E/fwebp',
  ];

  // [MỚI] Dữ liệu khoảng giá
  final List<Map<String, dynamic>> priceRanges = [
    {'label': 'Dưới 10 triệu', 'min': 0.0, 'max': 10000000.0},
    {'label': '10 - 20 triệu', 'min': 10000000.0, 'max': 20000000.0},
    {'label': '20 - 40 triệu', 'min': 20000000.0, 'max': 40000000.0},
    {'label': 'Trên 40 triệu', 'min': 40000000.0, 'max': null},
  ];

  @override
  void initState() {
    super.initState();
    _updateProductStream();
  }

  // Hàm tạo Query (Lọc & Sắp xếp)
  void _updateProductStream() {
    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('categoryId', isEqualTo: widget.categoryId);

    // 1. Lọc Brand
    if (_selectedBrand.isNotEmpty) {
      query = query.where('brand', isEqualTo: _selectedBrand);
    }

    // 2. Lọc Giá (Quan trọng: Cần tạo Index nếu dùng cái này)
    if (_minPrice != null) {
      query = query.where('basePrice', isGreaterThanOrEqualTo: _minPrice);
    }
    if (_maxPrice != null) {
      query = query.where('basePrice', isLessThanOrEqualTo: _maxPrice);
    }

    // 3. Sắp xếp
    if (_minPrice != null || _maxPrice != null) {
      // Nếu lọc giá -> Bắt buộc sort theo giá trước
      query = query.orderBy('basePrice', descending: _sortBy == 'priceDesc');
    } else {
      // Nếu không lọc giá -> Sort bình thường
      if (_sortBy == 'priceAsc') {
        query = query.orderBy('basePrice', descending: false);
      } else if (_sortBy == 'priceDesc') {
        query = query.orderBy('basePrice', descending: true);
      }
    }

    _productStream = query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPromotionalBanner(),
          _buildFilterTabs(),
          _buildSortAndFilterBar(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  // ... (Giữ nguyên _buildAppBar)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        height: 40,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm trong ${widget.categoryTitle}...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
          ),
        ),
      ),
    );
  }

  // ... (Giữ nguyên _buildPromotionalBanner)
  Widget _buildPromotionalBanner() {
    if (bannerImages.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 140.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 0.92,
            onPageChanged: (index, reason) => setState(() => _currentBannerIndex = index),
          ),
          items: bannerImages.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300)),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bannerImages.asMap().entries.map((entry) {
            return Container(
              width: 6.0, height: 6.0, margin: const EdgeInsets.symmetric(horizontal: 3.0),
              decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(_currentBannerIndex == entry.key ? 0.9 : 0.2)),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ... (Giữ nguyên _buildFilterTabs)
  Widget _buildFilterTabs() {
    // Nếu không có brand truyền vào thì tự tạo list demo để không bị trống
    List<String> tabs = widget.brands ?? ['Apple', 'Samsung', 'Xiaomi', 'Vivo', 'Oppo'];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final brandName = tabs[index];
          final isSelected = _selectedBrand == brandName;
          return ChoiceChip(
            label: Text(brandName),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedBrand = selected ? brandName : '';
                _updateProductStream();
              });
            },
            backgroundColor: Colors.white,
            selectedColor: primaryColor.withOpacity(0.1),
            labelStyle: TextStyle(color: isSelected ? primaryColor : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            side: BorderSide(color: isSelected ? primaryColor : Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  // ... (Giữ nguyên _buildSortAndFilterBar)
  Widget _buildSortAndFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(child: _buildSortItem('Phổ biến', 'popular')),
          Container(height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 12)),
          Expanded(child: _buildSortItem('Giá bán', 'price')),
          Container(height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 12)),
          InkWell(
            onTap: () => _showFilterDialog(),
            child: Row(children: [Text('Bộ lọc', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)), const SizedBox(width: 4), Icon(Icons.filter_list, color: Colors.grey.shade600, size: 18)]),
          ),
        ],
      ),
    );
  }

  Widget _buildSortItem(String label, String valueKey) {
    bool isActive = false;
    if (valueKey == 'popular' && _sortBy == 'popular') isActive = true;
    if (valueKey == 'price' && (_sortBy == 'priceAsc' || _sortBy == 'priceDesc')) isActive = true;
    return InkWell(
      onTap: () => _showSortOptions(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey.shade600, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
          Icon(Icons.arrow_drop_down, color: isActive ? primaryColor : Colors.grey.shade600),
        ],
      ),
    );
  }

  // ... (Giữ nguyên _buildProductGrid và _buildProductCard)
  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _productStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryColor));
        final products = snapshot.data!.docs;
        if (products.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off, size: 60, color: Colors.grey.shade300), const SizedBox(height: 16), const Text('Không tìm thấy sản phẩm nào', style: TextStyle(color: Colors.grey))]));
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.58),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final doc = products[index];
            final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
            return _buildProductCard(data);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> data) {
    String name = data['name'] ?? 'Sản phẩm';
    num basePrice = data['basePrice'] ?? 0;
    num originalPrice = data['originalPrice'] ?? (basePrice * 1.1);
    String imageUrl = (data['images'] != null && (data['images'] as List).isNotEmpty) ? (data['images'] as List)[0] : 'https://via.placeholder.com/150';
    String specs = data['description'] ?? '';
    double rating = (data['ratingAverage'] is num) ? (data['ratingAverage'] as num).toDouble() : 4.5;
    int discountPercent = originalPrice > basePrice ? (((originalPrice - basePrice) / originalPrice) * 100).round() : 0;

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Container(height: 150, color: Colors.grey.shade100))),
              if (discountPercent > 0) Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: Text('-$discountPercent%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ],
          ),
          Expanded(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4), Text(specs, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
            const Spacer(), Text(_formatCurrency(basePrice), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
            if (discountPercent > 0) Text(_formatCurrency(originalPrice), style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 11)),
            const SizedBox(height: 6),
            Row(children: [Icon(Icons.star, color: Colors.amber, size: 14), const SizedBox(width: 4), Text("$rating", style: const TextStyle(fontSize: 11)), const Spacer(), const Icon(Icons.favorite_border, size: 18, color: Colors.grey)])
          ]))),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Sắp xếp theo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSortRadio('Phổ biến', 'popular'), _buildSortRadio('Giá thấp đến cao', 'priceAsc'), _buildSortRadio('Giá cao đến thấp', 'priceDesc')
          ]),
        );
      },
    );
  }

  Widget _buildSortRadio(String title, String value) {
    return ListTile(title: Text(title, style: TextStyle(color: _sortBy == value ? primaryColor : Colors.black87)), trailing: _sortBy == value ? Icon(Icons.check, color: primaryColor) : null, onTap: () { setState(() { _sortBy = value; _updateProductStream(); }); Navigator.pop(context); });
  }

  // --- [ĐÃ SỬA] DIALOG BỘ LỌC HOÀN CHỈNH ---
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        // Dùng StatefulBuilder để cập nhật UI trong Dialog
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6, // Cao hơn để chứa đủ nội dung
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Bộ lọc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedBrand = '';
                                _selectedPriceRangeIndex = -1;
                                _minPrice = null;
                                _maxPrice = null;
                                _updateProductStream();
                              });
                              Navigator.pop(context);
                            },
                            child: Text('Xóa lọc', style: TextStyle(color: primaryColor)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // 1. Thương hiệu
                      const Text('Thương hiệu', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: (widget.brands ?? ['Apple', 'Samsung', 'Xiaomi', 'Vivo', 'Oppo']).map((brand) {
                          final isSelected = _selectedBrand == brand;
                          return FilterChip(
                            label: Text(brand),
                            selected: isSelected,
                            selectedColor: primaryColor.withOpacity(0.2),
                            labelStyle: TextStyle(color: isSelected ? primaryColor : Colors.black),
                            checkmarkColor: primaryColor,
                            onSelected: (selected) {
                              setStateModal(() {
                                _selectedBrand = selected ? brand : '';
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),
                      // 2. Mức giá (Phần này trước đây bị thiếu)
                      const Text('Mức giá', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(priceRanges.length, (index) {
                          final range = priceRanges[index];
                          final isSelected = _selectedPriceRangeIndex == index;
                          return FilterChip(
                            label: Text(range['label']),
                            selected: isSelected,
                            selectedColor: primaryColor.withOpacity(0.2),
                            labelStyle: TextStyle(color: isSelected ? primaryColor : Colors.black),
                            checkmarkColor: primaryColor,
                            onSelected: (selected) {
                              setStateModal(() {
                                if (selected) {
                                  _selectedPriceRangeIndex = index;
                                  _minPrice = range['min'];
                                  _maxPrice = range['max'];
                                } else {
                                  _selectedPriceRangeIndex = -1;
                                  _minPrice = null;
                                  _maxPrice = null;
                                }
                              });
                            },
                          );
                        }),
                      ),

                      const SizedBox(height: 30),
                      // Nút Áp dụng
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _updateProductStream(); // Cập nhật danh sách bên ngoài
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Xem kết quả', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatCurrency(num price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
  }
}