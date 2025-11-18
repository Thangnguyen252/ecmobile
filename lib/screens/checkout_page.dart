import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/models/cart_item_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Để decode JSON
import 'package:http/http.dart' as http; // Để gọi API
import 'package:ecmobile/models/address_model.dart'; // Model địa chỉ
import 'package:random_string/random_string.dart'; // Để tạo mã ngẫu nhiên
import 'package:ecmobile/screens/qr_payment_page.dart'; // Màn hình QR
import 'package:ecmobile/screens/payment_success_page.dart'; // --- THÊM IMPORT NÀY ---

// Định nghĩa các phương thức thanh toán
enum PaymentMethod { qr, cod }

// Model đơn giản cho Voucher
class Voucher {
  final String code;
  final double amount;
  final String description;

  Voucher(
      {required this.code, required this.amount, required this.description});
}

class CheckoutPage extends StatefulWidget {
  final List<CartItemModel> itemsToCheckout;

  const CheckoutPage({
    Key? key,
    required this.itemsToCheckout,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  // Controller để điều khiển TabBar
  late TabController _tabController;

  // --- Dữ liệu giả (PLACEHOLDER) cho thông tin người dùng ---
  String _userName = "Nguyễn Quang Thắng";
  String _userPhone = "0772983376";
  String _userEmail = "thangvh2004@gmail.com";
  bool _isStudent = true;
  bool _isMember = true;

  // Controller cho các ô text field
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _voucherCodeController = TextEditingController();

  // Voucher
  final List<Voucher> _availableVouchers = [
    Voucher(
        code: 'GIAM50K',
        amount: 50000.0,
        description: 'Giảm 50.000đ cho mọi đơn hàng'),
    Voucher(
        code: 'STUDENT',
        amount: 100000.0,
        description: 'Giảm 100.000đ (chỉ dành cho HSSV)'),
  ];
  double _appliedVoucherDiscount = 0.0;
  String? _appliedVoucherCode;

  // Payment Method
  PaymentMethod _selectedPaymentMethod = PaymentMethod.qr; // Mặc định là QR

  // --- STATE CHO DROPDOWN ĐỘNG ---
  List<Province> _provinces = [];
  List<District> _districts = [];
  List<Ward> _wards = [];

  Province? _selectedProvince;
  District? _selectedDistrict;
  Ward? _selectedWard;

  bool _isLoadingProvinces = true;
  bool _isLoadingDistricts = false;
  bool _isLoadingWards = false;

  // Các màu sắc từ Figma
  final Color figmaBgColor = const Color(0xFFF1F1F1);
  final Color figmaRedPrice = const Color(0xFFFE3A30);
  final Color figmaGreyText = const Color(0xFF8A8A8E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProvinces(); // Tải danh sách tỉnh/thành
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _voucherCodeController.dispose();
    super.dispose();
  }

  // --- CÁC HÀM GỌI API (ĐỊA CHỈ) ---
  Future<void> _loadProvinces() async {
    setState(() {
      _isLoadingProvinces = true;
    });
    try {
      final response = await http
          .get(Uri.parse('https://provinces.open-api.vn/api/p/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _provinces = data.map((json) => Province.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print("Error loading provinces: $e");
    } finally {
      setState(() {
        _isLoadingProvinces = false;
      });
    }
  }

  Future<void> _loadDistricts(int provinceCode) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _wards = [];
      _selectedDistrict = null;
      _selectedWard = null;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://provinces.open-api.vn/api/p/$provinceCode?depth=2'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> districtData = data['districts'];
        setState(() {
          _districts =
              districtData.map((json) => District.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print("Error loading districts: $e");
    } finally {
      setState(() {
        _isLoadingDistricts = false;
      });
    }
  }

  Future<void> _loadWards(int districtCode) async {
    setState(() {
      _isLoadingWards = true;
      _wards = [];
      _selectedWard = null;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://provinces.open-api.vn/api/d/$districtCode?depth=2'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> wardData = data['wards'];
        setState(() {
          _wards = wardData.map((json) => Ward.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print("Error loading wards: $e");
    } finally {
      setState(() {
        _isLoadingWards = false;
      });
    }
  }

  // --- LOGIC VOUCHER ---
  void _applyVoucher(String code) {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mã voucher'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final codeUpperCase = code.toUpperCase();
    final voucher = _availableVouchers.firstWhere(
          (v) => v.code.toUpperCase() == codeUpperCase,
      orElse: () =>
          Voucher(code: '', amount: 0.0, description: 'Không hợp lệ'),
    );

    if (voucher.amount > 0) {
      setState(() {
        _appliedVoucherDiscount = voucher.amount;
        _appliedVoucherCode = voucher.code;
        _voucherCodeController.text = voucher.code;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã áp dụng voucher ${voucher.code}!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        if (_appliedVoucherDiscount > 0) {
          _appliedVoucherDiscount = 0.0;
          _appliedVoucherCode = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã voucher không hợp lệ hoặc đã hết hạn.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    FocusScope.of(context).unfocus();
  }

  void _showVoucherPopup() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voucher có sẵn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                itemCount: _availableVouchers.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final voucher = _availableVouchers[index];
                  bool isApplied = _appliedVoucherCode == voucher.code;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      voucher.code,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isApplied
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(voucher.description),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isApplied ? Colors.grey : AppColors.primary,
                      ),
                      child: Text(isApplied ? 'Đã áp dụng' : 'Áp dụng'),
                      onPressed: isApplied
                          ? null
                          : () {
                        _applyVoucher(voucher.code);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // --- HÀM TIỆN ÍCH ---
  String _formatPrice(double price) {
    final format = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return format.format(price).replaceAll(RegExp(r'\s+'), '');
  }

  double _calculateTotalPrice() {
    return widget.itemsToCheckout.fold(
      0.0,
          (sum, item) => sum + item.getTotalCurrentPrice(),
    );
  }

  double _calculateTotalSaving() {
    return widget.itemsToCheckout.fold(
      0.0,
          (sum, item) => sum + item.getSavingAmount(),
    );
  }

  String _getFullAddress() {
    final address = _addressController.text;
    final ward = _selectedWard?.name ?? "";
    final district = _selectedDistrict?.name ?? "";
    final province = _selectedProvince?.name ?? "";
    return [address, ward, district, province]
        .where((s) => s.isNotEmpty)
        .join(", ");
  }

  void _navigateToPaymentTab() {
    if (_selectedProvince == null ||
        _selectedDistrict == null ||
        _selectedWard == null ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin nhận hàng.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _tabController.animateTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: figmaBgColor,
      body: Column(
        children: [
          _buildCheckoutAppBar(),
          _buildCustomTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildInfoTab(),
                _buildPaymentTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCheckoutAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: AppColors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Thông tin thanh toán',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      height: 48,
      color: AppColors.primary,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.white,
        indicatorWeight: 3,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
        labelColor: AppColors.white,
        labelStyle:
        const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        unselectedLabelColor: AppColors.white.withOpacity(0.7),
        unselectedLabelStyle:
        const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        tabs: const [
          Tab(text: 'Thông tin'),
          Tab(text: 'Thanh toán'),
        ],
      ),
    );
  }

  // --- TAB 1: THÔNG TIN ---
  Widget _buildInfoTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductListSection(),
                const SizedBox(height: 16),
                const Text(
                  'Thông tin nhận hàng',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildUserInfoSection(),
                const SizedBox(height: 18),
                _buildDynamicDropdown<Province>(
                  label: "Tỉnh/ Thành phố",
                  hint: "Chọn tỉnh/thành phố",
                  value: _selectedProvince,
                  items: _provinces,
                  isLoading: _isLoadingProvinces,
                  getItemName: (province) => province.name,
                  onChanged: (province) {
                    if (province != null) {
                      setState(() {
                        _selectedProvince = province;
                      });
                      _loadDistricts(province.code);
                    }
                  },
                ),
                _buildDynamicDropdown<District>(
                  label: "Quận/Huyện",
                  hint: "Chọn quận/huyện",
                  value: _selectedDistrict,
                  items: _districts,
                  isLoading: _isLoadingDistricts,
                  isEnabled:
                  _selectedProvince != null && !_isLoadingDistricts,
                  getItemName: (district) => district.name,
                  onChanged: (district) {
                    if (district != null) {
                      setState(() {
                        _selectedDistrict = district;
                      });
                      _loadWards(district.code);
                    }
                  },
                ),
                _buildDynamicDropdown<Ward>(
                  label: "Phường/Xã",
                  hint: "Chọn phường/xã",
                  value: _selectedWard,
                  items: _wards,
                  isLoading: _isLoadingWards,
                  isEnabled:
                  _selectedDistrict != null && !_isLoadingWards,
                  getItemName: (ward) => ward.name,
                  onChanged: (val) {
                    setState(() => _selectedWard = val);
                  },
                ),
                _buildTextField(
                  label: "Địa chỉ nhà",
                  hint: "Nhập địa chỉ nhà",
                  controller: _addressController,
                ),
                _buildTextField(
                  label: "Ghi chú",
                  hint: "Nhập ghi chú (nếu có)",
                  controller: _notesController,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
        _buildInfoTabFooter(),
      ],
    );
  }

  Widget _buildInfoTabFooter() {
    final double totalPrice = _calculateTotalPrice();
    final double totalSaving = _calculateTotalSaving();

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Tiết kiệm: ',
                  style: TextStyle(fontSize: 14, color: figmaGreyText),
                  children: [
                    TextSpan(
                      text: _formatPrice(totalSaving),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Tổng tiền: ',
                  style: TextStyle(fontSize: 14, color: figmaGreyText),
                  children: [
                    TextSpan(
                      text: _formatPrice(totalPrice),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _navigateToPaymentTab,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Tiếp tục thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: THANH TOÁN ---
  Widget _buildPaymentTab() {
    final String fullAddress = _getFullAddress();
    final String notes = _notesController.text.isNotEmpty
        ? _notesController.text
        : "Không có ghi chú";

    final double totalPrice = _calculateTotalPrice();
    final double totalSaving = _calculateTotalSaving();
    final double shippingFee = 0.0;
    final double finalTotal = totalPrice - _appliedVoucherDiscount;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductListSection(),
                const SizedBox(height: 16),
                _buildPaymentInfoSection(totalPrice, shippingFee,
                    _appliedVoucherDiscount, totalSaving),
                const SizedBox(height: 16),
                _buildPaymentMethodSection(),
                const SizedBox(height: 16),
                _buildReceiverInfoSection(fullAddress, notes),
                const SizedBox(height: 16),
                _buildTermsSection(),
              ],
            ),
          ),
        ),
        _buildPaymentFooter(finalTotal),
      ],
    );
  }

  Widget _buildPaymentInfoSection(double subtotal, double shippingFee,
      double voucherDiscount, double totalSaving) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin thanh toán',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voucherCodeController,
                  decoration: InputDecoration(
                    hintText: "Nhập mã khuyến mãi",
                    hintStyle: TextStyle(color: figmaGreyText),
                    filled: true,
                    fillColor: figmaBgColor,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () =>
                      _applyVoucher(_voucherCodeController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Áp dụng',
                    style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.primary),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _showVoucherPopup,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: figmaBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Voucher có sẵn',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceDetailRow(
              'Số lượng sản phẩm:', '${widget.itemsToCheckout.length}'),
          _buildPriceDetailRow('Tổng tiền hàng:', _formatPrice(subtotal)),
          _buildPriceDetailRow(
              'Phí vận chuyển:',
              shippingFee == 0.0 ? "Miễn phí" : _formatPrice(shippingFee),
              color: shippingFee == 0.0 ? const Color(0xFF2E7D32) : null),
          _buildPriceDetailRow('Giảm giá:', '-${_formatPrice(totalSaving)}',
              color: const Color(0xFF2E7D32)),
          _buildPriceDetailRow(
              'Mã giảm giá:', '-${_formatPrice(voucherDiscount)}',
              color: const Color(0xFF2E7D32)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildPaymentOption(
            title: 'Thanh toán khi nhận hàng',
            icon: Icons.local_shipping_outlined,
            value: PaymentMethod.cod,
          ),
          _buildPaymentOption(
            title: 'Quét mã QR chuyển khoản',
            icon: Icons.qr_code_2_outlined,
            value: PaymentMethod.qr,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      {required String title,
        required IconData icon,
        required PaymentMethod value}) {
    return RadioListTile<PaymentMethod>(
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (val) {
        setState(() {
          _selectedPaymentMethod = val!;
        });
      },
      activeColor: AppColors.primary,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      secondary: Icon(icon, color: AppColors.primary),
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildReceiverInfoSection(String fullAddress, String notes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin người nhận',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildReceiverInfoRow('Họ và tên:', _userName),
          _buildReceiverInfoRow('Số điện thoại:', _userPhone),
          _buildReceiverInfoRow('Nhận hàng tại:', fullAddress,
              isAddress: true),
          _buildReceiverInfoRow('Ghi chú:', notes),
        ],
      ),
    );
  }

  Widget _buildReceiverInfoRow(String title, String value,
      {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: isAddress ? 1.5 : 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text.rich(
        TextSpan(
          text: 'Bằng việc nhấn nút "Thanh toán", bạn đồng ý với ',
          style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary),
          children: [
            TextSpan(
              text: 'Điều khoản sử dụng',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' của chúng tôi.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPaymentFooter(double finalTotal) {
    final saving = _calculateTotalSaving();
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Tiết kiệm: ',
                  style: TextStyle(fontSize: 14, color: figmaGreyText),
                  children: [
                    TextSpan(
                      text: _formatPrice(saving),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32), // Màu xanh lá
                      ),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Tổng tiền: ',
                  style: TextStyle(fontSize: 14, color: figmaGreyText),
                  children: [
                    TextSpan(
                      text: _formatPrice(finalTotal),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // Kiểm tra phương thức thanh toán
                if (_selectedPaymentMethod == PaymentMethod.qr) {
                  // 1. Tạo mã giao dịch ngẫu nhiên (6 chữ + 3 số)
                  String randomContent =
                      '${randomAlpha(6).toUpperCase()}${randomNumeric(3)}';

                  // 2. Chuyển sang trang QR
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QRPaymentPage(
                        finalTotalAmount: finalTotal,
                        transactionContent: randomContent,
                      ),
                    ),
                  );
                } else {
                  // Logic cho COD (Thanh toán khi nhận hàng)
                  // Chuyển thẳng sang màn hình thanh toán thành công
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const PaymentSuccessPage(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CÁC WIDGET CON (COMMON) ---
  Widget _buildProductListSection() {
    return Column(
      children: widget.itemsToCheckout
          .map((item) => _buildProductCard(item))
          .toList(),
    );
  }

  Widget _buildProductCard(CartItemModel item) {
    final isAsset = !item.productImage.startsWith('http');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: isAsset
                      ? AssetImage(item.productImage) as ImageProvider
                      : NetworkImage(item.productImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatPrice(item.currentPrice),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: figmaRedPrice,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatPrice(item.originalPrice),
                        style: TextStyle(
                          fontSize: 12,
                          color: figmaGreyText,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Số lượng: ${item.quantity.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 13,
                      color: figmaGreyText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0.5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userPhone,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_isStudent)
                _buildUserBadge("Student", const Color(0xFF2E7D32)),
              if (_isMember) const SizedBox(width: 8),
              if (_isMember) _buildUserBadge("Member", AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            text == "Student"
                ? Icons.school_outlined
                : Icons.card_membership_outlined,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) getItemName,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            hint: Text(hint, style: TextStyle(color: figmaGreyText)),
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: isEnabled ? AppColors.white : Colors.grey[100],
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              suffixIcon: isLoading
                  ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
                  : const Icon(Icons.arrow_drop_down),
            ),
            onChanged: (isEnabled && !isLoading) ? onChanged : null,
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(getItemName(item),
                    overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: figmaGreyText),
              filled: true,
              fillColor: AppColors.white,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetailRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}