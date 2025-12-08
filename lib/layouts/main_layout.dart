
import 'package:ecmobile/screens/product_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/screens/home_page.dart';
import 'package:ecmobile/screens/cart_page.dart';
import 'package:ecmobile/widgets/custom_search_app_bar.dart';

// Đã xóa import đến màn hình chat

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  int _cartItemCount = 5; 

  // Chỉ còn 4 widget tương ứng với 4 tab
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const Center(child: Text('Trang Danh mục')),
    const Center(child: Text('Trang Đơn hàng')),
    const Center(child: Text('Trang Tài khoản')),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Logic đã được đơn giản hóa, không còn trường hợp đặc biệt
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartPage(),
      ),
    );
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductSearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomSearchAppBar(
        searchController: _searchController,
        cartItemCount: _cartItemCount,
        onCartPressed: _navigateToCart,
        onSearchTap: _navigateToSearch,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primary,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.white,
        unselectedItemColor: AppColors.white.withOpacity(0.7),
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        // Đã xóa item "AI hỗ trợ"
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Danh mục',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
