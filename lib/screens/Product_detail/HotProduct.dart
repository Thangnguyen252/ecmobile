import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../Product_detail/product_detail.dart';
import '../../services/customer_service.dart';
import '../../models/customer_model.dart';

class HotProductPage extends StatefulWidget {

  final String? initialCategory;

  const HotProductPage({Key? key, this.initialCategory}) : super(key: key);

  @override
  State<HotProductPage> createState() => _HotProductPageState();
}

class _HotProductPageState extends State<HotProductPage> with SingleTickerProviderStateMixin {
  final CustomerService _customerService = CustomerService();
  final Color primaryColor = const Color(0xFFFA661B);

  late AnimationController _animationController;
  String _selectedSort = 'rating'; // 'rating', 'price_low', 'price_high', 'newest'
  String _selectedCategory = 'all';

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'name': 'Tất cả'},
    {'id': 'cate_phone', 'name': 'Điện thoại'},
    {'id': 'cate_laptop', 'name': 'Laptop'},
    {'id': 'cate_audio', 'name': 'Âm thanh'},
    {'id': 'cate_monitor', 'name': 'Màn hình'},
    {'id': 'cate_tablet', 'name': 'Tablet'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getProductStream() {
    Query query = FirebaseFirestore.instance.collection('products');

    // Filter by category
    if (_selectedCategory != 'all') {
      query = query.where('categoryId', isEqualTo: _selectedCategory);
    }

    // Filter by rating (hot products have rating >= 4.0)
    query = query.where('ratingAverage', isGreaterThanOrEqualTo: 4.0);

    // Sort
    switch (_selectedSort) {
      case 'rating':
        query = query.orderBy('ratingAverage', descending: true);
        break;
      case 'price_low':
        query = query.orderBy('basePrice', descending: false);
        break;
      case 'price_high':
        query = query.orderBy('basePrice', descending: true);
        break;
      case 'newest':
        query = query.orderBy('createdAt', descending: true);
        break;
    }

    query = query.limit(20);
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Sản phẩm HOT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Animated fire icon
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_animationController.value * 0.2),
                  child: Icon(
                    Icons.whatshot,
                    color: Colors.yellow,
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<CustomerModel?>(
        stream: _customerService.getUserStream(),
        builder: (context, userSnapshot) {
          final user = userSnapshot.data;

          return Column(
            children: [
              _buildFilterSection(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getProductStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red),
                            SizedBox(height: 16),
                            Text('Lỗi tải dữ liệu: ${snapshot.error}'),
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: primaryColor));
                    }

                    final products = snapshot.data!.docs;

                    if (products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Chưa có sản phẩm HOT nào',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.48,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final doc = products[index];
                        final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
                        final isFavorite = user?.favoriteProducts.contains(data['id']) ?? false;

                        return HotProductCard(
                          data: data,
                          isFavorite: isFavorite,
                          rank: index + 1,
                          onToggleFavorite: () {
                            if (user != null) {
                              _customerService.toggleFavoriteProduct(data['id']);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category['name']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category['id']!;
                      });
                    },
                    selectedColor: primaryColor,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 8),
          // Sort options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildSortChip('Đánh giá cao', 'rating'),
                _buildSortChip('Giá thấp', 'price_low'),
                _buildSortChip('Giá cao', 'price_high'),
                _buildSortChip('Mới nhất', 'newest'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _selectedSort == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) Icon(Icons.check, size: 16, color: Colors.white),
            if (isSelected) SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSort = value;
          });
        },
        selectedColor: primaryColor,
        backgroundColor: Colors.grey.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 13,
        ),
      ),
    );
  }
}

class HotProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isFavorite;
  final int rank;
  final VoidCallback onToggleFavorite;

  const HotProductCard({
    Key? key,
    required this.data,
    required this.isFavorite,
    required this.rank,
    required this.onToggleFavorite,
  }) : super(key: key);

  String formatCurrency(num price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(price);
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.orange.shade300;
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFFA661B);
    String name = data['name'] ?? 'Sản phẩm';
    num rawPrice = data['basePrice'] ?? 0;
    String imageUrl = (data['images'] != null && (data['images'] as List).isNotEmpty)
        ? (data['images'] as List)[0]
        : 'https://via.placeholder.com/150';
    num oldPrice = data['originalPrice'] ?? (rawPrice * 1.2);
    double rating = (data['ratingAverage'] is num) ? (data['ratingAverage'] as num).toDouble() : 4.5;
    String productId = data['id'];
    int discount = ((oldPrice - rawPrice) / oldPrice * 100).round();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: productId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                    ),
                  ),
                ),
                // HOT badge with flame
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade600, Colors.orange.shade500],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'HOT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Discount badge
                if (discount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-$discount%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Rank badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getRankColor(rank),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          color: rank <= 3 ? Colors.white : Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                // Christmas hat
                Positioned(
                  top: -12,
                  left: -12,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Transform.scale(
                      scaleX: -1,
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/744/744546.png',
                        width: 28,
                        height: 28,
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
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Bán chạy',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      formatCurrency(rawPrice),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formatCurrency(oldPrice),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Xem chi tiết',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
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
      ),
    );
  }
}