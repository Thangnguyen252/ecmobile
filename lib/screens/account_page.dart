import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/models/customer_model.dart';
import 'package:ecmobile/services/customer_service.dart';
import 'package:intl/intl.dart';
import 'package:ecmobile/screens/student_verify_page.dart';
// --- THÊM IMPORT TRANG MỚI ---
import 'package:ecmobile/screens/user_info_page.dart';import 'package:ecmobile/screens/membership_rules_page.dart';
class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final CustomerService _customerService = CustomerService();

  // Helper định dạng tiền
  String _formatPrice(double price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return format.format(price).replaceAll(RegExp(r'\s+'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Nền xám nhạt
      // Dùng StreamBuilder để lấy dữ liệu realtime
      body: StreamBuilder<CustomerModel?>(
        stream: _customerService.getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Không tải được thông tin tài khoản"));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. Header (Avatar + Info)
                _buildHeader(user),

                // 2. Thống kê (Stats)
                _buildStatsSection(user),

                const SizedBox(height: 16),

                // 3. Menu Options (Đã cập nhật)
                _buildMenuSection(user),

                const SizedBox(height: 24),

                // 4. Logout Button
                _buildLogoutButton(),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET CON ---

  // 1. Header Profile
  Widget _buildHeader(CustomerModel user) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24), // Padding top 48 để tránh status bar
      child: Row(
        children: [
          // Avatar (Dùng ảnh mạng hoặc placeholder)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[200]!, width: 2),
              image: const DecorationImage(
                image: NetworkImage("https://i.pravatar.cc/300?img=12"), // Avatar mẫu
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.nickname.isNotEmpty ? "@${user.nickname}" : user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Rank Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1), // Vàng nhạt
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFC107)), // Viền vàng
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond_outlined, size: 14, color: Color(0xFFFFC107)),
                      const SizedBox(width: 4),
                      Text(
                        user.membershipRank, // "Kim cương"
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8F00), // Cam đậm
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          // Edit Icon (Góc phải)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
          )
        ],
      ),
    );
  }

  // 2. Thống kê (2 ô vuông)
  Widget _buildStatsSection(CustomerModel user) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Ô 1: Đơn hàng
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FF), // Xanh nhạt
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 24),
                  const SizedBox(height: 8),
                  const Text("Đơn hàng đã mua", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    "${user.purchasedOrderCount}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blue),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Ô 2: Tổng chi tiêu
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5E5), // Cam nhạt
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFFF8F00), size: 24),
                  const SizedBox(height: 8),
                  const Text("Tổng chi tiêu", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(user.totalSpending),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.green),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Menu List (Đã cập nhật icon cam và divider đều nhau)
  Widget _buildMenuSection(CustomerModel user) {
    // Định nghĩa Divider chung để tái sử dụng
    const divider = Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE));

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: "Thông tin cá nhân",
            subtitle: "Chỉnh sửa thông tin, địa chỉ",
            onTap: () {
              // Điều hướng sang trang Cập nhật thông tin
              // Truyền object 'user' hiện tại sang để điền sẵn vào form
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserInfoPage(user: user),
                ),
              );
            },
          ),
          divider,
          _buildMenuItem(
            icon: Icons.card_membership,
            title: "Hạng thành viên",
            trailingText: user.membershipRank, // Lấy từ Firebase
            onTap: () {
              // Điều hướng sang trang Quy tắc thành viên
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MembershipRulesPage(
                    currentRank: user.membershipRank, // Truyền rank hiện tại để highlight
                  ),
                ),
              );
            },
          ),
          divider,
          _buildMenuItem(
            icon: Icons.school_outlined,
            title: "Học sinh - Sinh viên",
            trailingText: user.isStudent ? "Đã xác thực" : "Chưa xác thực",
            onTap: () {
              // Nếu đã là sinh viên rồi thì có thể hiện thông báo "Đã xác thực"
              // Nếu chưa, chuyển sang trang xác thực
              if (user.isStudent) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bạn đã được xác thực là HSSV!')),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentVerifyPage(),
                  ),
                );
              }
            },
          ),
          divider,
          _buildMenuItem(
            icon: Icons.receipt_long_outlined,
            title: "Lịch sử đơn hàng",
            subtitle: "Xem lại các đơn hàng cũ",
            onTap: () {},
          ),
          divider,
          _buildMenuItem(
            icon: Icons.favorite_border,
            title: "Sản phẩm yêu thích",
            trailingText: "12", // Số lượng demo
            onTap: () {},
          ),
          divider,
          _buildMenuItem(
            icon: Icons.history,
            title: "Đã xem gần đây",
            onTap: () {},
          ),
          divider,
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: "Đổi mật khẩu",
            onTap: () {},
          ),
          divider,
          _buildMenuItem(
            icon: Icons.headphones_outlined,
            title: "Hỗ trợ khách hàng",
            onTap: () {},
          ),
          divider,
          _buildMenuItem(
            icon: Icons.info_outline,
            title: "Về ứng dụng",
            trailingText: "v1.0.0",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    required VoidCallback onTap
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFA661B).withOpacity(0.1), // Nền cam nhạt
          shape: BoxShape.circle,
        ),
        // Icon màu cam primary FA661B
        child: Icon(icon, color: const Color(0xFFFA661B), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  // 4. Logout Button
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: () {
            // Logic đăng xuất
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            foregroundColor: Colors.red, // Màu chữ và hiệu ứng click
          ),
          child: const Text("Đăng xuất", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}