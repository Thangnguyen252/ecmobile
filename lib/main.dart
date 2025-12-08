import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/layouts/main_layout.dart';
import 'package:ecmobile/screens/product_detail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Mua sắm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.white,
        ),
      ),

      // --- PHẦN QUAN TRỌNG ĐÃ SỬA ---
      routes: {
        // Route này sẽ nhận ID động từ HomePage
        '/product-detail': (context) {
          // 1. Lấy arguments được gửi kèm từ Navigator.pushNamed
          final args = ModalRoute.of(context)!.settings.arguments;

          // 2. Kiểm tra an toàn: Nếu args là String thì dùng, nếu null thì mặc định là 'ip17_pro'
          final String productId = (args is String) ? args : 'ip17_pro';

          // 3. Trả về màn hình chi tiết với ID thực
          return ProductDetailScreen(productId: productId);
        },
      },
      // -----------------------------

      home: const MainLayout(),
    );
  }
}