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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          'HỆ THỐNG CHẤM CÔNG GPS - TRANG QUẢN TRỊ ADMIN',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.white),
              SizedBox(width: 8),
              Text('Xin chào, Super Admin', style: TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // TODO: Thực hiện hàm await FirebaseAuth.instance.signOut()
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            }, 
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            extended: true, 
            backgroundColor: Colors.grey[50],
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics, color: Colors.indigo), label: Text('Bảng Tổng Quan')),
              NavigationRailDestination(icon: Icon(Icons.badge_outlined), selectedIcon: Icon(Icons.badge, color: Colors.indigo), label: Text('Quản Lý Nhân Viên')),
              NavigationRailDestination(icon: Icon(Icons.assignment_turned_in_outlined), selectedIcon: Icon(Icons.assignment_turned_in, color: Colors.indigo), label: Text('Nhật Ký Chấm Công')),
              NavigationRailDestination(icon: Icon(Icons.mail_outline), selectedIcon: Icon(Icons.mail, color: Colors.indigo), label: Text('Duyệt Nghỉ Phép')),
              NavigationRailDestination(icon: Icon(Icons.pin_drop_outlined), selectedIcon: Icon(Icons.pin_drop, color: Colors.indigo), label: Text('Cấu Hình Vị Trí GPS')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1), 
          Expanded(
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(24),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
    