import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecmobile/models/customer_model.dart';
import 'package:ecmobile/screens/Product_detail/product_detail.dart';
import 'package:ecmobile/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventChristmasPage extends StatefulWidget {
  const EventChristmasPage({Key? key}) : super(key: key);

  @override
  State<EventChristmasPage> createState() => _EventChristmasPageState();
}

class _EventChristmasPageState extends State<EventChristmasPage> with TickerProviderStateMixin {
  final CustomerService _customerService = CustomerService();
  final Color xmasRed = const Color(0xFFD32F2F);
  final Color xmasGreen = const Color(0xFF388E3C);

  // --- TRẠNG THÁI ---
  bool _isOpened = false;
  bool _showOverlay = true;

  // Controllers
  late AnimationController _shakeController;
  late AnimationController _openController;

  // Animations
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _lidOffsetAnimation;
  late Animation<double> _lidRotateAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Rung lắc
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOutSine),
    );
    _shakeController.repeat(reverse: true);

    // 2. Mở quà - OPTIMIZED: Shorter duration
    _openController = AnimationController(
      duration: const Duration(milliseconds: 1800), // Faster!
      vsync: this,
    );

    // OPTIMIZED: Scale nhỏ hơn, kết thúc sớm hơn
    _scaleAnimation = Tween<double>(begin: 1.0, end: 8.0).animate(
      CurvedAnimation(
          parent: _openController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeInQuad) // Shorter interval
      ),
    );

    // Nắp bay lên
    _lidOffsetAnimation = Tween<double>(begin: -80, end: -400).animate(
      CurvedAnimation(parent: _openController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutQuad)),
    );

    _lidRotateAnimation = Tween<double>(begin: 0, end: 1.2).animate(
      CurvedAnimation(parent: _openController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    // CRITICAL: Fade out entire overlay quickly
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _openController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _openController, curve: const Interval(0.5, 0.8, curve: Curves.linear)),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _openController.dispose();
    super.dispose();
  }

  void _handleOpenGift() {
    if (_openController.isAnimating || _openController.isCompleted) return;
    _shakeController.stop();
    _openController.forward().then((value) {
      // Remove overlay immediately after animation
      if (mounted) {
        setState(() {
          _isOpened = true;
          _showOverlay = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ===========================================
          // LỚP 1: NỘI DUNG SẢN PHẨM
          // ===========================================
          Scaffold(
            backgroundColor: Colors.red.shade50,
            appBar: AppBar(
              backgroundColor: xmasRed,
              elevation: 0,
              title: const Text("🎅 Giáng Sinh An Lành 🎄", style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: StreamBuilder<CustomerModel?>(
              stream: _customerService.getUserStream(),
              builder: (context, userSnapshot) {
                final user = userSnapshot.data;
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: xmasRed,
                          image: const DecorationImage(
                            image: NetworkImage('https://static.vecteezy.com/system/resources/previews/004/364/337/non_2x/christmas-banner-background-xmas-objects-viewed-from-above-winter-sale-vector.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.bottomLeft,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SIÊU SALE CUỐI NĂM",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                              ),
                              Text(
                                "Giảm giá đến 50% toàn bộ cửa hàng",
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.ac_unit, color: xmasRed),
                            const SizedBox(width: 8),
                            Text("DÀNH RIÊNG CHO BẠN", style: TextStyle(color: xmasRed, fontWeight: FontWeight.bold, fontSize: 18)),
                            const Spacer(),
                            Icon(Icons.ac_unit, color: xmasRed),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('products').limit(20).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                        final products = snapshot.data!.docs;
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.58, mainAxisSpacing: 12, crossAxisSpacing: 12),
                            delegate: SliverChildBuilderDelegate((context, index) {
                              final doc = products[index];
                              final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
                              final isFavorite = user?.favoriteProducts.contains(data['id']) ?? false;
                              return _buildChristmasCard(data, isFavorite, () { if (user != null) _customerService.toggleFavoriteProduct(data['id']); });
                            }, childCount: products.length),
                          ),
                        );
                      },
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  ],
                );
              },
            ),
          ),

          // =========================================
          // LỚP 2: TUYẾT RƠI - ONLY WHEN OPENED
          // =========================================
          if (_isOpened)
            IgnorePointer(
              ignoring: true,
              child: RepaintBoundary(
                child: SnowfallAnimation(numberOfFlakes: 60), // Further reduced
              ),
            ),

          // =========================================
          // LỚP 3: HỘP QUÀ (Overlay) - OPTIMIZED
          // =========================================
          if (_showOverlay)
            GestureDetector(
              onTap: _handleOpenGift,
              child: AnimatedBuilder(
                animation: _openController,
                builder: (context, child) {
                  // CRITICAL: Fade out entire container early
                  return Opacity(
                    opacity: _fadeOutAnimation.value,
                    child: Container(
                      color: const Color(0xFF1a2f23),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // --- HỘP QUÀ 3D - SIMPLIFIED ---
                            RepaintBoundary( // Isolate this expensive widget
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Opacity(
                                  opacity: _opacityAnimation.value,
                                  child: AnimatedBuilder(
                                    animation: _shakeController,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _openController.isAnimating ? 0 : _shakeAnimation.value,
                                        child: child,
                                      );
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        // 1. THÂN HỘP - Simplified shadows
                                        Container(
                                          width: 180,
                                          height: 160,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD32F2F),
                                            borderRadius: const BorderRadius.only(
                                                bottomLeft: Radius.circular(12),
                                                bottomRight: Radius.circular(12)
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  blurRadius: 15, // Reduced
                                                  offset: const Offset(0, 10)
                                              )
                                            ],
                                            gradient: const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [Color(0xFFEF5350), Color(0xFFB71C1C)]
                                            ),
                                          ),
                                          child: Center(
                                              child: Container(
                                                  width: 30,
                                                  height: double.infinity,
                                                  color: const Color(0xFFFFD700)
                                              )
                                          ),
                                        ),

                                        // 2. NẮP HỘP
                                        Transform.translate(
                                          offset: Offset(0, _lidOffsetAnimation.value),
                                          child: Transform.rotate(
                                            angle: _lidRotateAnimation.value,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              clipBehavior: Clip.none,
                                              children: [
                                                Container(
                                                  width: 200, height: 50,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFE53935),
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 5,
                                                          offset: const Offset(0, 5)
                                                      )
                                                    ],
                                                  ),
                                                  child: Center(
                                                      child: Container(
                                                          width: 30,
                                                          height: double.infinity,
                                                          color: const Color(0xFFFFD700)
                                                      )
                                                  ),
                                                ),
                                                Positioned(
                                                  top: -25,
                                                  child: Container(
                                                    width: 50, height: 50,
                                                    decoration: const BoxDecoration(
                                                        color: Color(0xFFFFD700),
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors.black12,
                                                              blurRadius: 4,
                                                              offset: Offset(0, 2)
                                                          )
                                                        ]
                                                    ),
                                                    child: const Icon(Icons.star, color: Colors.orange, size: 30),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 100),
                            if (!_openController.isAnimating)
                              Column(
                                children: [
                                  const Text(
                                      "BẠN CÓ QUÀ!",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5
                                      )
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                      "Chạm vào hộp để mở ngay",
                                      style: TextStyle(color: Colors.white70, fontSize: 16)
                                  ),
                                ],
                              )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChristmasCard(Map<String, dynamic> data, bool isFavorite, VoidCallback onToggleFavorite) {
    String name = data['name'] ?? 'Sản phẩm';
    num basePrice = data['basePrice'] ?? 0;
    num originalPrice = data['originalPrice'] ?? (basePrice * 1.2);
    String imageUrl = (data['images'] != null && (data['images'] as List).isNotEmpty) ? (data['images'] as List)[0] : 'https://via.placeholder.com/150';
    String productId = data['id'];
    int discount = ((originalPrice - basePrice) / originalPrice * 100).round();

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: productId)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: xmasRed.withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(color: xmasGreen.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Container(height: 140, color: Colors.grey.shade100),
                  ),
                ),
                Positioned(
                  top: -18,
                  left: -18,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Transform.scale(
                      scaleX: -1,
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/744/744546.png',
                        width: 40,
                        errorBuilder: (c,e,s) => const SizedBox(),
                      ),
                    ),
                  ),
                ),
                if (discount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: xmasGreen, borderRadius: BorderRadius.circular(4)),
                      child: Text('-$discount%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(basePrice),
                          style: TextStyle(color: xmasRed, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(originalPrice),
                          style: TextStyle(color: Colors.grey.shade400, decoration: TextDecoration.lineThrough, fontSize: 11),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: xmasRed.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: xmasRed.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.card_giftcard, size: 14, color: xmasRed),
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Text(
                              "Tặng tất Noel + Thiệp",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// OPTIMIZED SNOWFALL WIDGET
// ==========================================================
class SnowfallAnimation extends StatefulWidget {
  final int numberOfFlakes;

  const SnowfallAnimation({Key? key, this.numberOfFlakes = 60}) : super(key: key);

  @override
  State<SnowfallAnimation> createState() => _SnowfallAnimationState();
}

class _SnowfallAnimationState extends State<SnowfallAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Snowflake> _snowflakes;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _snowflakes = List.generate(widget.numberOfFlakes, (index) => _createSnowflake());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void didUpdateWidget(SnowfallAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.numberOfFlakes != oldWidget.numberOfFlakes) {
      _snowflakes = List.generate(widget.numberOfFlakes, (index) => _createSnowflake());
    }
  }

  Snowflake _createSnowflake() {
    return Snowflake(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        speed: _random.nextDouble() * 0.003 + 0.001,
        opacity: _random.nextDouble() * 0.6 + 0.3
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var flake in _snowflakes) {
          flake.y += flake.speed;
          if (flake.y > 1.0) {
            flake.y = -0.05;
            flake.x = _random.nextDouble();
          }
        }
        return CustomPaint(
          size: Size.infinite,
          painter: SnowPainter(_snowflakes),
        );
      },
    );
  }
}

class Snowflake {
  double x, y, size, speed, opacity;
  Snowflake({required this.x, required this.y, required this.size, required this.speed, required this.opacity});
}

class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;

  SnowPainter(this.snowflakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var flake in snowflakes) {
      canvas.drawCircle(
        Offset(flake.x * size.width, flake.y * size.height),
        flake.size,
        paint..color = Colors.white.withOpacity(flake.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}