import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Cần import intl để format tiền tệ
import '../models/chat_model.dart';

class GroqService {
  // --- KEY GROQ (GIỮ NGUYÊN CỦA BẠN) ---
  static const String _apiKey = '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';

  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper: Format tiền tệ VNĐ (Ví dụ: 30.590.000)
  String _formatCurrency(num price) {
    final format = NumberFormat("#,###", "vi_VN");
    return format.format(price);
  }

  // 1. Hàm xử lý dữ liệu thông minh (Smart Parser)
  Future<String> _getProductContext() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').limit(50).get();

      if (snapshot.docs.isEmpty) return "Hiện chưa có dữ liệu sản phẩm nào.";

      StringBuffer buffer = StringBuffer();
      buffer.writeln("DANH SÁCH SẢN PHẨM CHI TIẾT:");

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // 1. Thông tin cơ bản
        String name = data['name'] ?? 'Sản phẩm';
        String brand = data['brand'] ?? '';
        String category = data['categoryId'] ?? '';

        // 2. Xử lý GIÁ TIỀN & PHIÊN BẢN (Logic quan trọng)
        // Dữ liệu mẫu cho thấy có 'variants' (iPhone, Màn hình) hoặc chỉ có 'basePrice' (Loa, Laptop)
        String priceInfo = "";
        List<dynamic> variants = data['variants'] ?? [];

        if (variants.isNotEmpty) {
          // Trường hợp 1: Có nhiều phiên bản (Ví dụ iPhone: 256GB, 512GB...)
          List<String> variantDetails = [];
          for (var v in variants) {
            var attrs = v['attributes'] ?? {};
            String color = attrs['color'] ?? '';
            String storage = attrs['storage'] ?? ''; // Dung lượng (nếu có)
            num vPrice = v['price'] ?? 0;

            String detail = "$color";
            if (storage.isNotEmpty) detail += " $storage";
            detail += ": ${_formatCurrency(vPrice)} VNĐ";

            variantDetails.add(detail);
          }
          priceInfo = "Các phiên bản: ${variantDetails.join(' | ')}";
        } else {
          // Trường hợp 2: Sản phẩm đơn (Loa, Laptop) -> Dùng basePrice
          num basePrice = data['basePrice'] ?? data['originalPrice'] ?? 0;
          priceInfo = "Giá: ${_formatCurrency(basePrice)} VNĐ";
        }

        // 3. Xử lý THÔNG SỐ KỸ THUẬT (Specifications)
        // Map này chứa thông tin quan trọng như Chip, Ram, Pin...
        String specInfo = "";
        Map<String, dynamic> specs = data['specifications'] ?? {};
        if (specs.isNotEmpty) {
          List<String> specList = [];
          specs.forEach((key, value) {
            // Làm đẹp key một chút (chip -> Chip, battery_life -> Battery Life)
            String cleanKey = key.replaceAll('_', ' ').toUpperCase();
            specList.add("$cleanKey: $value");
          });
          specInfo = specList.join(", ");
        }

        // 4. Ghi vào bộ nhớ đệm cho AI
        buffer.writeln("---");
        buffer.writeln("Sản phẩm: $name ($brand - $category)");
        buffer.writeln(priceInfo);
        if (specInfo.isNotEmpty) buffer.writeln("Thông số: $specInfo");
        buffer.writeln("Mô tả: ${data['description'] ?? ''}");
      }
      return buffer.toString();
    } catch (e) {
      print("Lỗi parse dữ liệu: $e");
      return "Lỗi đọc dữ liệu sản phẩm.";
    }
  }

  // 2. Hàm gửi tin nhắn (Giữ nguyên logic gọi API)
  Future<String> sendMessageToGroq(String userMessage, List<ChatMessage> history) async {
    try {
      String productContext = await _getProductContext();

      // Cập nhật System Prompt để AI chú ý vào giá từng phiên bản
      String systemPrompt = """
      Bạn là trợ lý ảo bán hàng của EC Mobile.
      Dữ liệu sản phẩm được cung cấp bên dưới bao gồm: Tên, Giá (có thể có nhiều phiên bản), Thông số kỹ thuật.
      
      YÊU CẦU:
      1. Khi khách hỏi giá, hãy kiểm tra xem có các "phiên bản" khác nhau không. Nếu có, hãy liệt kê giá của từng phiên bản (ví dụ: Bản 256GB giá A, bản 512GB giá B).
      2. Nếu khách hỏi cấu hình (pin, chip, ram...), hãy tìm trong phần "Thông số".
      3. Trả lời ngắn gọn, chính xác, dùng tiếng Việt.
      4. Đơn vị tiền tệ là VNĐ.

      $productContext
      """;

      List<Map<String, String>> messages = [];
      messages.add({"role": "system", "content": systemPrompt});

      int historyLimit = history.length > 6 ? 6 : history.length;
      var recentHistory = history.sublist(history.length - historyLimit);

      for (var m in recentHistory) {
        messages.add({
          "role": m.role == 'user' ? 'user' : 'assistant',
          "content": m.content
        });
      }
      messages.add({"role": "user", "content": userMessage});

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.6, // Giảm temperature để AI trả lời chính xác giá hơn
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        print("Lỗi Groq: ${response.body}");
        return "Hệ thống đang bảo trì.";
      }

    } catch (e) {
      print("Lỗi Exception: $e");
      return "Lỗi kết nối.";
    }
  }
}