
import 'package:ecmobile/screens/product_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/screens/home_page.dart';
import 'package:ecmobile/screens/cart_page.dart';
import 'package:ecmobile/widgets/custom_search_app_bar.dart';
// --- THÊM IMPORT TRANG TÀI KHOẢN ---
import 'package:ecmobile/screens/account_page.dart';
import 'package:ecmobile/screens/ai_support_page.dart'; // IMPORT TRANG MỚI

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // --- QUẢN LÝ STATE CHO APPBAR ---
  // Vì AppBar giờ đã thuộc về MainLayout,
  // MainLayout phải chịu trách nhiệm quản lý state của nó.
  final TextEditingController _searchController = TextEditingController();
  int _cartItemCount = 5;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const Center(child: Text('Trang Danh mục')),
    const Center(child: Text('Trang Đơn hàng')),
    const AiSupportPage(), // THAY THẾ TEXT BẰNG TRANG AI
    const Center(child: Text('Trang Tài khoản')),
    const AccountPage(), // Thay Text bằng AccountPage
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      // Ẩn AppBar nếu đang ở trang AI (vì trang AI có AppBar riêng)
      appBar: _selectedIndex == 3
          ? null
          : CustomSearchAppBar(
        searchController: _searchController,
        cartItemCount: _cartItemCount,
      appBar: CustomSearchAppBar(
        searchController: _searchController,
        cartItemCount: _cartItemCount,
        onCartPressed: _navigateToCart,
        onSearchTap: _navigateToSearch,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.white,
            unselectedItemColor: AppColors.white.withOpacity(0.7),
            selectedLabelStyle:
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
