import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

void main() async {
  // ✅ QUAN TRỌNG: Khởi tạo Flutter bindings trước
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  print('🚀 Đang khởi tạo Firebase...');
  await Firebase.initializeApp();
  print('✅ Firebase đã được khởi tạo!');

  // Gọi hàm thêm variants
  await addVariantsToProduct();

  // Thoát script sau khi hoàn tất
  print('👋 Script đã hoàn tất. Nhấn Ctrl+C hoặc q để thoát.');
}

Future<void> addVariantsToProduct() async {
  try {
    print('\n📦 Bắt đầu thêm variants vào sản phẩm iPhone 16 Pro Max...');

    // ID của sản phẩm cần cập nhật
    String productId = 'ip16_promax';

    // Định nghĩa variants mới
    List<Map<String, dynamic>> variants = [
      // Titan Đen - 256GB
      {
        'attributes': {
          'color': 'Titan Đen',
          'storage': '256GB',
          'imageURL': 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/i/p/iphone-16-pro-max-titan-den.png'
        },
        'price': 30590000,
        'sku': 'ip16pm_den_256gb',
        'stock': 50
      },
      // Titan Đen - 512GB
      {
        'attributes': {
          'color': 'Titan Đen',
          'storage': '512GB',
          'imageURL': 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/i/p/iphone-16-pro-max-titan-den.png'
        },
        'price': 35590000,
        'sku': 'ip16pm_den_512gb',
        'stock': 30
      },
      // Titan Đen - 1TB
      {
        'attributes': {
          'color': 'Titan Đen',
          'storage': '1TB',
          'imageURL': 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/i/p/iphone-16-pro-max-titan-den.png'
        },
        'price': 40590000,
        'sku': 'ip16pm_den_1tb',
        'stock': 6
      },

      // Titan Trắng - 256GB
      {
        'attributes': {
          'color': 'Titan Trắng',
          'storage': '256GB',
          'imageURL': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-16-pro-max.png'
        },
        'price': 30590000,
        'sku': 'ip16pm_trang_256gb',
        'stock': 40
      },
      // Titan Trắng - 512GB
      {
        'attributes': {
          'color': 'Titan Trắng',
          'storage': '512GB',
          'imageURL': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-16-pro-max.png'
        },
        'price': 35590000,
        'sku': 'ip16pm_trang_512gb',
        'stock': 5
      },
      // Titan Trắng - 1TB
      {
        'attributes': {
          'color': 'Titan Trắng',
          'storage': '1TB',
          'imageURL': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-16-pro-max.png'
        },
        'price': 40590000,
        'sku': 'ip16pm_trang_1tb',
        'stock': 3
      },

      // Titan Sa mạc - 256GB
      {
        'attributes': {
          'color': 'Titan Sa mạc',
          'storage': '256GB',
          'imageURL': 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/i/p/iphone-16-pro-max-titan-sa-mac.png'
        },
        'price': 30590000,
        'sku': 'ip16pm_samac_256gb',
        'stock': 15
      },
      // Titan Sa mạc - 1TB
      {
        'attributes': {
          'color': 'Titan Sa mạc',
          'storage': '1TB',
          'imageURL': 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/i/p/iphone-16-pro-max-titan-sa-mac.png'
        },
        'price': 40590000,
        'sku': 'ip16pm_samac_1tb',
        'stock': 5
      }
    ];

    // Hiển thị thông tin
    print('📝 Tổng số variants: ${variants.length}');
    print('🎯 Product ID: $productId\n');

    // In chi tiết từng variant
    for (int i = 0; i < variants.length; i++) {
      var v = variants[i];
      print('Variant ${i + 1}:');
      print('  - Màu: ${v['attributes']['color']}');
      print('  - Dung lượng: ${v['attributes']['storage']}');
      print('  - Giá: ${_formatPrice(v['price'])}');
      print('  - SKU: ${v['sku']}');
      print('  - Tồn kho: ${v['stock']}');
      print('');
    }

    // Cập nhật vào Firestore
    print('💾 Đang cập nhật vào Firestore...');
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({
      'variants': variants,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Đã cập nhật thành công ${variants.length} variants!');
    print('🎉 Hoàn tất!\n');

    // Hiển thị summary
    _printSummary(variants);
  } catch (e) {
    print('❌ Lỗi: $e');
    rethrow;
  }
}

// Hàm format giá tiền
String _formatPrice(int price) {
  return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫';
}

// Hàm hiển thị tóm tắt
void _printSummary(List<Map<String, dynamic>> variants) {
  print('═══════════════════════════════════════');
  print('📊 TÓM TẮT');
  print('═══════════════════════════════════════');

  // Đếm theo màu
  Map<String, int> colorCount = {};
  for (var v in variants) {
    String color = v['attributes']['color'];
    colorCount[color] = (colorCount[color] ?? 0) + 1;
  }

  print('\n🎨 Phân bổ theo màu:');
  colorCount.forEach((color, count) {
    print('  - $color: $count variants');
  });

  // Đếm theo dung lượng
  Map<String, int> storageCount = {};
  for (var v in variants) {
    String storage = v['attributes']['storage'];
    storageCount[storage] = (storageCount[storage] ?? 0) + 1;
  }

  print('\n💾 Phân bổ theo dung lượng:');
  storageCount.forEach((storage, count) {
    print('  - $storage: $count variants');
  });

  // Tính tổng tồn kho
  int totalStock = variants.fold(0, (sum, v) => sum + (v['stock'] as int));
  print('\n📦 Tổng tồn kho: $totalStock sản phẩm');

  // Giá min-max
  List<int> prices = variants.map((v) => v['price'] as int).toList();
  int minPrice = prices.reduce((a, b) => a < b ? a : b);
  int maxPrice = prices.reduce((a, b) => a > b ? a : b);
  print('\n💰 Khoảng giá: ${_formatPrice(minPrice)} - ${_formatPrice(maxPrice)}');

  print('═══════════════════════════════════════\n');
}