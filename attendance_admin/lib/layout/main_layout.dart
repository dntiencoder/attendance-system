import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../shared/theme/app_colors.dart';
import 'sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao thực tế của toàn bộ khung hình trình duyệt Web
    final double screenHeight = MediaQuery.of(context).size.height;
    // Tính toán tỷ lệ 1/5 chiều cao khung hình cho thanh Header phía trên
    final double appBarHeight = screenHeight / 5;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: const Color(0xFFB91C1C), // Màu Đỏ UMC chủ đạo
          elevation: 3,
          centerTitle: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // KHỐI LOGO UMC VÀ TIÊU ĐỀ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo_umc.jpg',
                          width: 85, 
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 85, color: Color(0xFFB91C1C)),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'UMC ATTENDANCE SYSTEM',
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 26, 
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'HỆ THỐNG QUẢN TRỊ VÀ GIÁM SÁT CHẤM CÔNG REALTIME',
                            style: TextStyle(
                              color: Color(0xFFFECACA), 
                              fontWeight: FontWeight.w500, 
                              fontSize: 14, 
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // NÚT ĐĂNG XUẤT
                  OutlinedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.power_settings_new_rounded, size: 24),
                    label: const Text(
                      'ĐĂNG XUẤT', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Row(
        children: [
          const SizedBox(width: 260, child: Sidebar()),
          const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE2E8F0)), 
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.all(32), 
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
