// Enum cho các loại khuyến mãi
enum PromoType { student, member, warranty }

// Class cho thông tin khuyến mãi
class PromoInfo {
  final String text;
  final PromoType type;
  final List<String> subPromos; // Danh sách các khuyến mãi con (nếu có)

  PromoInfo({
    required this.text,
    required this.type,
    this.subPromos = const [], // Mặc định là rỗng
  });
}

// Class cho một item trong giỏ hàng
class CartItemModel {
  final String cartItemId;
  final String productId;
  final String productName;
  final String productImage;
  final double currentPrice; // Dùng double cho nhất quán
  final double originalPrice; // Dùng double
  int quantity;
  bool isSelected;
  final List<PromoInfo> promos; // Danh sách các khuyến mãi

  CartItemModel({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.currentPrice,
    required this.originalPrice,
    required this.quantity,
    this.isSelected = false,
    required this.promos,
  });

  // --- Hàm tính toán ---
  double getTotalCurrentPrice() {
    return currentPrice * quantity;
  }

  double getSavingAmount() {
    return (originalPrice - currentPrice) * quantity;
  }
}