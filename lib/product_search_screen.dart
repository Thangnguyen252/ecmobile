
import 'package:ecmobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Data model for a trending search item
class SearchTrendItem {
  final String name;
  final String imagePath;

  SearchTrendItem({required this.name, required this.imagePath});
}

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({Key? key}) : super(key: key);

  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Mock data for trending searches - replace with real data later
  final List<SearchTrendItem> _trendingItems = [
    SearchTrendItem(name: "iPhone 17 Series", imagePath: "assets/images/iphone.png"),
    SearchTrendItem(name: "Samsung Z Fold7", imagePath: "assets/images/zfold.png"),
    SearchTrendItem(name: "iPhone Air", imagePath: "assets/images/iphone_air.png"),
    SearchTrendItem(name: "Airpod pro 3", imagePath: "assets/images/airpods.png"),
    SearchTrendItem(name: "MacBook Pro M5", imagePath: "assets/images/macbook.png"),
    SearchTrendItem(name: "iPad Pro M5", imagePath: "assets/images/ipad.png"),
    SearchTrendItem(name: "Vivo V60 Lite", imagePath: "assets/images/vivo.png"),
    SearchTrendItem(name: "Oppo Find X9", imagePath: "assets/images/oppo.png"),
    SearchTrendItem(name: "Tai nghe Sony", imagePath: "assets/images/sony_headphones.png"),
    SearchTrendItem(name: "Laptop ASUS ROG", imagePath: "assets/images/asus_laptop.png"),
  ];

  @override
  void initState() {
    super.initState();
    // Automatically focus the search field to show the keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary, // <<< FIXED: Using the correct theme color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
              hintText: "Bạn muốn mua gì hôm nay?",
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        titleSpacing: 10.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Xu hướng tìm kiếm",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 2.5,
                ),
                itemCount: _trendingItems.length,
                itemBuilder: (context, index) {
                  final item = _trendingItems[index];
                  return SearchTrendCard(item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchTrendCard extends StatelessWidget {
  final SearchTrendItem item;

  const SearchTrendCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to the product page or search results page
        print("Tapped on ${item.name}");
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image, color: Colors.grey)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
