
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
  final Color primaryColor = const Color(0xFFFA661B);

  // Filter states
  String _sortBy = 'popular';
  double? _minPrice;
  double? _maxPrice;
  int _selectedPriceRangeIndex = -1;

  final List<Map<String, dynamic>> priceRanges = [
    {'label': 'Dưới 10 triệu', 'min': 0.0, 'max': 10000000.0},
    {'label': '10 - 20 triệu', 'min': 10000000.0, 'max': 20000000.0},
    {'label': '20 - 40 triệu', 'min': 20000000.0, 'max': 40000000.0},
    {'label': 'Trên 40 triệu', 'min': 40000000.0, 'max': null},
  ];

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

    if (_minPrice != null) {
      results = results.where((p) => p.basePrice >= _minPrice!).toList();
    }
    if (_maxPrice != null) {
      results = results.where((p) => p.basePrice <= _maxPrice!).toList();
    }

    if (_sortBy == 'priceAsc') {
      results.sort((a, b) => a.basePrice.compareTo(b.basePrice));
    } else if (_sortBy == 'priceDesc') {
      results.sort((a, b) => b.basePrice.compareTo(a.basePrice));
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
              children: [
                _buildSortAndFilterBar(),
                Expanded(
                  child: _buildProductGrid(user),
                ),
              ],
            );
          }),
    );
  }

  Widget _buildSortAndFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(child: _buildSortItem('Phổ biến', 'popular')),
          Container(
              height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 12)),
          Expanded(child: _buildSortItem('Giá bán', 'price')),
          Container(
              height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 12)),
          InkWell(
            onTap: () => _showFilterDialog(),
            child: Row(children: [
              Text('Bộ lọc', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(width: 4),
              Icon(Icons.filter_list, color: Colors.grey.shade600, size: 18)
            ]),
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
          Text(label,
              style: TextStyle(
                  color: isActive ? primaryColor : Colors.grey.shade600,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14)),
          Icon(Icons.arrow_drop_down, color: isActive ? primaryColor : Colors.grey.shade600),
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
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Sắp xếp theo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildSortRadio('Phổ biến', 'popular'),
                _buildSortRadio('Giá thấp đến cao', 'priceAsc'),
                _buildSortRadio('Giá cao đến thấp', 'priceDesc')
              ]),
        );
      },
    );
  }

  Widget _buildSortRadio(String title, String value) {
    return ListTile(
        title: Text(title, style: TextStyle(color: _sortBy == value ? primaryColor : Colors.black87)),
        trailing: _sortBy == value ? Icon(Icons.check, color: primaryColor) : null,
        onTap: () {
          setState(() {
            _sortBy = value;
            _runFilter(_searchController.text);
          });
          Navigator.pop(context);
        });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Bộ lọc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedPriceRangeIndex = -1;
                                _minPrice = null;
                                _maxPrice = null;
                                _runFilter(_searchController.text);
                              });
                              Navigator.pop(context);
                            },
                            child: Text('Xóa lọc', style: TextStyle(color: primaryColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _runFilter(_searchController.text);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Xem kết quả',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
