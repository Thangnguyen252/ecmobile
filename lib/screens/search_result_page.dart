
import 'package:ecmobile/models/customer_model.dart';
import 'package:ecmobile/services/customer_service.dart';
import 'package:ecmobile/widgets/reusable_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecmobile/theme/app_colors.dart';

// Model và ProductCard giữ nguyên như cũ...

class Product {
  final String id;
  final String name;
  final String description;
  final num basePrice;
  final num? originalPrice;
  final List<String> images;
  final double ratingAverage;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    this.originalPrice,
    required this.images,
    required this.ratingAverage,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Sản phẩm không tên',
      description: data['description'] ?? '',
      basePrice: data['basePrice'] ?? 0,
      originalPrice: data['originalPrice'],
      images: List<String>.from(data['images'] ?? []),
      ratingAverage: (data['ratingAverage'] as num? ?? 4.5).toDouble(),
    );
  }
}

class SearchResultPage extends StatefulWidget {
  final String searchQuery;
  final List<Product> products;
  final List<Product> allProducts;

  const SearchResultPage(
      {Key? key, required this.searchQuery, required this.products, required this.allProducts})
      : super(key: key);

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  final CustomerService _customerService = CustomerService();
  final TextEditingController _searchController = TextEditingController();
  late List<Product> _foundProducts;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _foundProducts = widget.products;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runFilter(String keyword) {
    List<Product> results;
    if (keyword.isEmpty) {
      results = widget.allProducts; // Nếu xóa hết chữ, tìm trên toàn bộ
    } else {
      String lowerCaseKeyword = keyword.toLowerCase();
      results = widget.allProducts.where((product) {
        return product.name.toLowerCase().contains(lowerCaseKeyword);
      }).toList();
    }
    setState(() {
      _foundProducts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: ReusableSearchBar(
          controller: _searchController,
          autofocus: true,
          hintText: "Tìm kiếm sản phẩm...",
          onChanged: _runFilter,
        ),
      ),
      body: StreamBuilder<CustomerModel?>(
          stream: _customerService.getUserStream(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            return Column(
              // Thêm Column để chứa các bộ lọc sau này
              children: [
                // TODO: Thêm các chip lọc (Tất cả, Liên quan, Mới nhất) ở đây
                const SizedBox(height: 16), // Khoảng cách nhỏ

                // *** FIX: Thêm Expanded để GridView có thể cuộn ***
                Expanded(
                  child: _buildProductGrid(user),
                ),
              ],
            );
          }),
    );
  }

  Widget _buildProductGrid(CustomerModel? user) {
    if (_foundProducts.isEmpty) {
      return const Center(
        child: Text(
          "Không tìm thấy sản phẩm nào.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.48,
      ),
      itemCount: _foundProducts.length,
      itemBuilder: (context, index) {
        final product = _foundProducts[index];
        final isFavorite = user?.favoriteProducts.contains(product.id) ?? false;
        return ProductCard(
          product: product,
          isFavorite: isFavorite,
          onToggleFavorite: () {
            if (user != null) {
              _customerService.toggleFavoriteProduct(product.id);
            }
          },
        );
      },
    );
  }
}

// ProductCard giữ nguyên như cũ
class ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const ProductCard({
    Key? key,
    required this.product,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : super(key: key);

  String formatCurrency(num price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = product.images.isNotEmpty ? product.images[0] : '';
    num oldPrice = product.originalPrice ?? (product.basePrice * 1.1);

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
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                        ),
                      )
                    : Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
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
                  Text(product.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(product.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8),
                  Text(formatCurrency(product.basePrice),
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  if (product.originalPrice != null)
                    Text(formatCurrency(oldPrice),
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12)),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(product.ratingAverage.toString(), style: TextStyle(fontSize: 12))
                      ]),
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
