import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

void main() async {
  // Khởi tạo Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  print('🚀 Đang khởi tạo Firebase...');
  await Firebase.initializeApp();
  print('✅ Firebase đã được khởi tạo!');

  // Gọi hàm thêm variants cho tai nghe Sony
  await addHeadphoneVariants();

  print('👋 Script đã hoàn tất. Nhấn Ctrl+C hoặc q để thoát.');
}

Future<void> addHeadphoneVariants() async {
  try {
    print('\n🎧 Bắt đầu thêm variants cho tai nghe Sony WH-CH520...');

    // ID của sản phẩm tai nghe
    String productId = 'sony_wh_ch520';

    // Giá cơ bản
    int basePrice = 1190000;
    int originalPrice = 1290000;

    // Định nghĩa variants cho tai nghe (chỉ có màu, không có dung lượng)
    List<Map<String, dynamic>> variants = [
      // Màu Xanh
      {
        'attributes': {
          'color': 'Xanh',
          'imageURL': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/a/tai-nghe-khong-day-sony-wh-ch520-xanh_2.jpg'
        },
        'price': basePrice,
        'originalPrice': originalPrice,
        'sku': 'ch520_blue',
        'stock': 40
      },

      // Màu Be (Kem)
      {
        'attributes': {
          'color': 'Be',
          'imageURL': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/o/sony-wh-ch520-go-3.png'
        },
        'price': basePrice,
        'originalPrice': originalPrice,
        'sku': 'ch520_beige',
        'stock': 35
      },

      // Màu Đen
      {
        'attributes': {
          'color': 'Đen',
          'imageURL': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/a/tai-nghe-chup-tai-sony-wh-ch520-_2_.png'
        },
        'price': basePrice,
        'originalPrice': originalPrice,
        'sku': 'ch520_black',
        'stock': 50
      },

      // Màu Trắng
      {
        'attributes': {
          'color': 'Trắng',
          'imageURL': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/o/sony-wh-ch520-2.png'
        },
        'price': basePrice,
        'originalPrice': originalPrice,
        'sku': 'ch520_white',
        'stock': 45
      }
    ];

    // Hiển thị thông tin
    print('📝 Tổng số variants: ${variants.length}');
    print('🎯 Product ID: $productId');
    print('💰 Giá gốc: ${_formatPrice(originalPrice)}');
    print('💰 Giá khuyến mãi: ${_formatPrice(basePrice)}\n');

    // In chi tiết từng variant
    for (int i = 0; i < variants.length; i++) {
      var v = variants[i];
      print('Variant ${i + 1}:');
      print('  - Màu: ${v['attributes']['color']}');
      print('  - Giá: ${_formatPrice(v['price'])}');
      print('  - Giá gốc: ${_formatPrice(v['originalPrice'])}');
      print('  - SKU: ${v['sku']}');
      print('  - Tồn kho: ${v['stock']} cái');
      print('  - Ảnh: ${v['attributes']['imageURL'].substring(0, 60)}...');
      print('');
    }

    // Cập nhật vào Firestore
    print('💾 Đang cập nhật vào Firestore...');
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({
      'variants': variants,
      'basePrice': basePrice,
      'originalPrice': originalPrice,
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

  print('\n🎨 Các màu sắc có sẵn:');
  colorCount.forEach((color, count) {
    var variant = variants.firstWhere((v) => v['attributes']['color'] == color);
    print('  - $color: ${variant['stock']} cái');
  });

  // Tính tổng tồn kho
  int totalStock = variants.fold(0, (sum, v) => sum + (v['stock'] as int));
  print('\n📦 Tổng tồn kho: $totalStock cái');

  // Giá
  int price = variants[0]['price'];
  int originalPrice = variants[0]['originalPrice'];
  int discount = originalPrice - price;
  double discountPercent = (discount / originalPrice * 100);

  print('\n💰 Thông tin giá:');
  print('  - Giá gốc: ${_formatPrice(originalPrice)}');
  print('  - Giá khuyến mãi: ${_formatPrice(price)}');
  print('  - Tiết kiệm: ${_formatPrice(discount)} (${discountPercent.toStringAsFixed(1)}%)');

  print('═══════════════════════════════════════\n');
}