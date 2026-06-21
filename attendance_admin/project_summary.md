# Project: Attendance Admin System (UMC)

This is a Flutter-based admin dashboard for an attendance tracking system.

## File Structure
- `pubspec.yaml`: Project configuration and dependencies.
- `lib/main.dart`: Entry point of the application.
- `lib/presentation/screens/login_screen.dart`: System login screen.
- `lib/presentation/screens/main_dashboard.dart`: Main container with sidebar navigation.
- `lib/presentation/screens/overview_screen.dart`: Dashboard overview with statistics.
- `lib/presentation/screens/employee_screen.dart`: Employee management interface.
- `lib/presentation/screens/attendance_screen.dart`: Attendance logs and reports.
- `lib/presentation/screens/leave_screen.dart`: Leave request approval interface.
- `lib/presentation/screens/settings_screen.dart`: GPS and office configuration.
- `lib/presentation/widgets/stat_card.dart`: Reusable widget for statistics.

---

## 1. pubspec.yaml
```yaml
name: attendance_admin
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.12.1

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^4.10.0
  firebase_auth: ^6.5.2
  cloud_firestore: ^6.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/logo_umc.jpg
```

---

## 2. lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'presentation/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hệ Thống Quản Trị Chấm Công UMC',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB91C1C),
          primary: const Color(0xFFB91C1C),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(), 
    );
  }
}
```

---

## 3. lib/presentation/screens/login_screen.dart
```dart
import 'package:flutter/material.dart';
import 'main_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          width: 450, 
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    const Icon(Icons.business, size: 100, color: Color(0xFFB91C1C)),
                    const SizedBox(height: 16),
                    const Text(
                      'UMC ATTENDANCE SYSTEM', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFB91C1C), letterSpacing: 0.5),
                    ),
                    const Text(
                      'Hệ Thống Quản Trị Chấm Công GPS', 
                      style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                const Text(
                  'ĐĂNG NHẬP HỆ THỐNG',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập tài khoản email';
                    if (value != 'admin@company.com') return 'Tài khoản admin không đúng';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tài khoản Email',
                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xFFB91C1C)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                    if (value != 'admin123') return 'Mật khẩu không chính xác';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFFB91C1C)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminMainDashboard()),
                      );
                    }
                  },
                  icon: const Icon(Icons.login_rounded),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  label: const Text('ĐĂNG NHẬP HỆ THỐNG', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 4. lib/presentation/screens/main_dashboard.dart
```dart
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = screenHeight / 5;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: const Color(0xFFB91C1C),
          elevation: 3,
          centerTitle: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                          ],
                        ),
                        child: const Icon(Icons.business, size: 50, color: Color(0xFFB91C1C)),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 32), 
                          SizedBox(width: 10),
                          Text(
                            'Xin chào, Super Admin', 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
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
            minExtendedWidth: 260, 
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
              padding: const EdgeInsets.all(32), 
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 5. lib/presentation/screens/overview_screen.dart
```dart
import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.dashboard_customize_rounded, color: Color(0xFFB91C1C)),
              SizedBox(width: 8),
              Text('Tổng Quan Hệ Thống Hôm Nay', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              const StatCard(title: 'Tổng số nhân viên', value: '150', icon: Icons.people_alt_rounded, color: Colors.blue),
              const StatCard(title: 'Đã Check-In', value: '132', icon: Icons.check_circle_rounded, color: Colors.green),
              const StatCard(title: 'Đi muộn', value: '8', icon: Icons.warning_amber_rounded, color: Colors.orange),
              const StatCard(title: 'Đơn phép chờ duyệt', value: '5', icon: Icons.hourglass_top_rounded, color: Color(0xFFB91C1C)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 400,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(12), 
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.insert_chart_rounded, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Khung hiển thị đồ thị thống kê chuyên cần', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
```

---

## 6. lib/presentation/screens/employee_screen.dart
```dart
import 'package:flutter/material.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final List<Map<String, String>> _employees = [
    {'id': 'NV001', 'name': 'Nguyễn Văn A', 'email': 'nguyenvana@company.com', 'role': 'Employee'},
    {'id': 'NV002', 'name': 'Trần Thị B', 'email': 'tranthib@company.com', 'role': 'Manager'},
  ];

  void _showAddEmployeeDialog() {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'Employee';
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.person_add_rounded, color: Color(0xFFB91C1C)),
              SizedBox(width: 8),
              Text('Thêm Nhân Viên Mới', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Form(
              key: dialogFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: codeController, decoration: const InputDecoration(labelText: 'Mã nhân viên', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))))),
                  const SizedBox(height: 16),
                  TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và tên', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))))),
                  const SizedBox(height: 16),
                  TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Địa chỉ Email', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))))),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Quyền hạn', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                    items: const [
                      DropdownMenuItem(value: 'Employee', child: Text('Employee')),
                      DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    ],
                    onChanged: (v) { if (v != null) selectedRole = v; },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
            ElevatedButton.icon(
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  setState(() {
                    _employees.add({'id': codeController.text, 'name': nameController.text, 'email': emailController.text, 'role': selectedRole});
                  });
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save_rounded),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB91C1C), foregroundColor: Colors.white),
              label: const Text('Lưu lại'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.badge_rounded, color: Color(0xFFB91C1C)),
                SizedBox(width: 8),
                Text('Danh Sách Hồ Sơ Nhân Sự UMC', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showAddEmployeeDialog, 
              icon: const Icon(Icons.add_circle_outline_rounded),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB91C1C), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              label: const Text('Thêm Nhân Viên Mới'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: ListView(
              children: [
                DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  columns: const [
                    DataColumn(label: Text('Mã NV', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Họ Tên', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Quyền hạn', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _employees.map((emp) {
                    return DataRow(cells: [
                      DataCell(Text(emp['id']!, style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(emp['name']!)),
                      DataCell(Text(emp['email']!)),
                      DataCell(Text(emp['role']!)),
                      DataCell(IconButton(
                        icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red), 
                        onPressed: () { setState(() { _employees.remove(emp); }); }
                      )),
                    ]);
                  }).toList(),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
```

---

## 7. lib/presentation/screens/attendance_screen.dart
```dart
import 'package:flutter/material.dart';

class AttendanceLogScreen extends StatelessWidget {
  const AttendanceLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.assignment_turned_in_rounded, color: Color(0xFFB91C1C)),
                SizedBox(width: 8),
                Text('Nhật Ký Chấm Công Toàn Cầu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 18),
                  label: const Text('Xuất PDF', style: TextStyle(color: Color(0xFF1E293B))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.grid_on_rounded, color: Colors.green, size: 18),
                  label: const Text('Xuất Excel', style: TextStyle(color: Color(0xFF1E293B))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: ListView(
              children: [
                DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  columns: const [
                    DataColumn(label: Text('Ngày chấm', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nhân viên', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check-In', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check-Out', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('08/06/2026')),
                      DataCell(Text('Nguyễn Văn A', style: TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text('07:55 AM')),
                      DataCell(Text('17:05 PM')),
                      DataCell(Chip(
                        label: Text('Đúng giờ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)), 
                        backgroundColor: Color(0xFFDCFCE7), 
                        side: BorderSide.none
                      )),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
```

---

## 8. lib/presentation/screens/leave_screen.dart
```dart
import 'package:flutter/material.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  final List<Map<String, String>> _requests = [
    {'name': 'Lê Văn C', 'reason': 'Xin nghỉ ốm đi khám răng định kỳ', 'range': '09/06 đến 10/06', 'status': 'Chờ xử lý'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.rate_review_rounded, color: Color(0xFFB91C1C)),
            SizedBox(width: 8),
            Text('Phê Duyệt Đơn Xin Nghỉ Phép', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: ListView(
              children: [
                DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  columns: const [
                    DataColumn(label: Text('Nhân viên', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Lý do xin nghỉ', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Khoảng thời gian', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Quyết định', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _requests.map((req) {
                    final bool isPending = req['status'] == 'Chờ xử lý';
                    return DataRow(cells: [
                      DataCell(Text(req['name']!, style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(req['reason']!)),
                      DataCell(Text(req['range']!)),
                      DataCell(Chip(
                        label: Text(req['status']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: req['status'] == 'Đã duyệt' ? Colors.green : (req['status'] == 'Từ chối' ? Colors.red : Colors.orange))),
                        backgroundColor: req['status'] == 'Đã duyệt' ? const Color(0xFFDCFCE7) : (req['status'] == 'Từ chối' ? const Color(0xFFFEE2E2) : const Color(0xFFFEF9C3)),
                        side: BorderSide.none,
                      )),
                      DataCell(isPending 
                        ? Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle_rounded, color: Colors.green), 
                                onPressed: () { setState(() { req['status'] = 'Đã duyệt'; }); }
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_rounded, color: Colors.red), 
                                onPressed: () { setState(() { req['status'] = 'Từ chối'; }); }
                              ),
                            ],
                          )
                        : const Text('Đã xử lý xong', style: TextStyle(color: Colors.grey, fontSize: 13))),
                    ]);
                  }).toList(),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
```

---

## 9. lib/presentation/screens/settings_screen.dart
```dart
import 'package:flutter/material.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final _officeController = TextEditingController(text: 'Trụ sở chính công ty UMC');
  final _latController = TextEditingController(text: '10.762622');
  final _lngController = TextEditingController(text: '106.660172');
  final _radiusController = TextEditingController(text: '100');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _officeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.fmd_good_rounded, color: Color(0xFFB91C1C)),
            SizedBox(width: 8),
            Text('Thiết Lập Tọa Độ Văn Phòng & Bán Kính Định Vị', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(12), 
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 500, 
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _officeController,
                            validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tên văn phòng' : null,
                            decoration: const InputDecoration(labelText: 'Tên địa điểm', prefixIcon: Icon(Icons.business_rounded, color: Color(0xFFB91C1C)), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _latController,
                            validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập vĩ độ' : null,
                            decoration: const InputDecoration(labelText: 'Tọa độ Vĩ độ (Latitude)', prefixIcon: Icon(Icons.explore_outlined, color: Color(0xFFB91C1C)), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _lngController,
                            validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập kinh độ' : null,
                            decoration: const InputDecoration(labelText: 'Tọa độ Kinh độ (Longitude)', prefixIcon: Icon(Icons.explore_outlined, color: Color(0xFFB91C1C)), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _radiusController,
                            validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập bán kính quét' : null,
                            decoration: const InputDecoration(labelText: 'Bán kính (Mét)', prefixIcon: Icon(Icons.radar_rounded, color: Color(0xFFB91C1C)), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật cấu hình định vị GPS!')));
                        }
                      }, 
                      icon: const Icon(Icons.cloud_upload_rounded),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB91C1C), 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      label: const Text('Lưu Thay Đổi Cấu Hình GPS'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
```

---

## 10. lib/presentation/widgets/stat_card.dart
```dart
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), 
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
              Icon(icon, size: 36, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
```
