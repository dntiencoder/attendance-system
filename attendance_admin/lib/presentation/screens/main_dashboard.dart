import 'package:flutter/material.dart';
import 'overview_screen.dart';
import 'employee_screen.dart';
import 'attendance_screen.dart';
import 'leave_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class AdminMainDashboard extends StatefulWidget {
  const AdminMainDashboard({super.key});

  @override
  State<AdminMainDashboard> createState() => _AdminMainDashboardState();
}

class _AdminMainDashboardState extends State<AdminMainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const OverviewScreen(),
    const EmployeeManagementScreen(),
    const AttendanceLogScreen(),
    const LeaveRequestsScreen(),
    const CompanySettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao thực tế của toàn bộ khung hình trình duyệt Web
    final double screenHeight = MediaQuery.of(context).size.height;
    // Tính toán tỷ lệ 1/5 chiều cao khung hình cho thanh Dashboard phía trên
    final double appBarHeight = screenHeight / 5;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        // Ép buộc thanh AppBar chiếm đúng tỷ lệ 1/5 chiều cao màn hình Web
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: const Color(0xFFB91C1C), // Màu Đỏ UMC chủ đạo
          elevation: 3,
          // Bỏ tính năng tự căn giữa mặc định để kiểm soát padding thủ công
          centerTitle: false,
          // Sử dụng flexibleSpace để dàn đều cấu trúc nội dung bự ra theo chiều dọc
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // LƯU TRÚ KHỐI LOGO UMC VÀ TIÊU ĐỀ ĐÃ PHÓNG TO 
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white, // Nền trắng làm nổi bật logo đỏ
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo_umc.jpg',
                          width: 85, // Phóng to Logo UMC trên thanh điều hướng
                          fit: BoxFit.contain,
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
                              fontSize: 26, // Chữ tiêu đề bự rõ ràng
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
                  
                  // LƯU TRÚ KHỐI THÔNG TIN TÀI KHOẢN VÀ NÚT ĐĂNG XUẤT ĐÃ PHÓNG TO
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 32), // Icon bự
                          SizedBox(width: 10),
                          Text(
                            'Xin chào, Super Admin', 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      // Thiết kế lại nút Đăng xuất to rõ, có viền trắng nổi bật
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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
                ],
              ),
            ),
          ),
        ),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            extended: true, 
            backgroundColor: Colors.white, 
            minExtendedWidth: 260, // Tăng độ rộng Sidebar để tương xứng với AppBar bự
            unselectedIconTheme: const IconThemeData(color: Color(0xFF64748B), size: 24),
            selectedIconTheme: const IconThemeData(color: Color(0xFFB91C1C), size: 26),
            unselectedLabelTextStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500, fontSize: 15),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold, fontSize: 16),
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: Text('Bảng Tổng Quan')),
              NavigationRailDestination(icon: Icon(Icons.badge_outlined), selectedIcon: Icon(Icons.badge), label: Text('Quản Lý Nhân Viên')),
              NavigationRailDestination(icon: Icon(Icons.assignment_turned_in_outlined), selectedIcon: Icon(Icons.assignment_turned_in), label: Text('Nhật Ký Chấm Công')),
              NavigationRailDestination(icon: Icon(Icons.mail_outline_rounded), selectedIcon: Icon(Icons.mail_rounded), label: Text('Duyệt Nghỉ Phép')),
              NavigationRailDestination(icon: Icon(Icons.pin_drop_outlined), selectedIcon: Icon(Icons.pin_drop), label: Text('Cấu Hình Vị Trí GPS')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE2E8F0)), 
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.all(32), // Tăng padding vùng nội dung cho thoáng đạt
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}