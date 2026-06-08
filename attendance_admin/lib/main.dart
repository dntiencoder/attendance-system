import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetApp(
      title: 'Giao Diện Hệ Thống Chấm Công',
      debugShowCheckedModeBanner: false, // Ẩn chữ DEBUG góc màn hình
      home: const AdminMainDashboard(),
    );
  }

  // Tiện ích bọc MaterialApp tiêu chuẩn để đồng bộ cấu hình Material 3
  Widget WidgetApp({required String title, required bool debugShowCheckedModeBanner, required Widget home}) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: home,
    );
  }
}


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
            onPressed: () {}, // Nút bấm thuần giao diện
          ),
          const SizedBox(width: 15),
        ],
      ),
      

      body: Row(
        children: [

          NavigationRail(
            selectedIndex: _selectedIndex,
            extended: true, // Mở rộng để hiển thị cả chữ kèm Icon
            backgroundColor: Colors.grey[50],
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index; // Chỉ thay đổi giao diện khi nhấn menu
              });
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics, color: Colors.indigo),
                label: Text('Bảng Tổng Quan'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.badge_outlined),
                selectedIcon: Icon(Icons.badge, color: Colors.indigo),
                label: Text('Quản Lý Nhân Viên'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment_turned_in_outlined),
                selectedIcon: Icon(Icons.assignment_turned_in, color: Colors.indigo),
                label: Text('Nhật Ký Chấm Công'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.mail_outline),
                selectedIcon: Icon(Icons.mail, color: Colors.indigo),
                label: Text('Duyệt Nghỉ Phép'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pin_drop_outlined),
                selectedIcon: Icon(Icons.pin_drop, color: Colors.indigo),
                label: Text('Cấu Hình Vị Trí GPS'),
              ),
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

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tổng Quan Hệ Thống Hôm Nay', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
  
        Row(
          children: [
            _buildStatCard('Tổng số nhân viên', '150', Icons.people, Colors.blue),
            _buildStatCard('Đã Check-In', '132', Icons.check_circle, Colors.green),
            _buildStatCard('Đi muộn', '8', Icons.warning, Colors.orange),
            _buildStatCard('Đơn phép chờ duyệt', '5', Icons.pending, Colors.red),
          ],
        ),
        const SizedBox(height: 30),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Text(
                'Khung hiển thị đồ thị thống kê (Mockup Chart Area)', 
                style: TextStyle(color: Colors.grey, fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          ),
        )
      ],
    );
  }


  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 1,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 10),
                  Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              Icon(icon, size: 40, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class EmployeeManagementScreen extends StatelessWidget {
  const EmployeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Danh Sách Quản Lý Nhân Viên', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {}, // Nút tĩnh
              icon: const Icon(Icons.add),
              label: const Text('Thêm Nhân Viên Mới'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 20),

        Expanded(
          child: Card(
            color: Colors.white,
            child: ListView(
              children: [
                DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                  columns: const [
                    DataColumn(label: Text('Mã NV', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Họ Tên', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Quyền hạn', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    DataRow(cells: [
                      const DataCell(Text('NV001')),
                      const DataCell(Text('Nguyễn Văn A')),
                      const DataCell(Text('nguyenvana@company.com')),
                      const DataCell(Text('Employee')),
                      DataCell(Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                        ],
                      )),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('NV002')),
                      const DataCell(Text('Trần Thị B')),
                      const DataCell(Text('tranthib@company.com')),
                      const DataCell(Text('Manager')),
                      DataCell(Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                        ],
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
            const Text('Nhật Ký Chấm Công Toàn Cầu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {}, // Bản mockup giao diện nút bấm
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  label: const Text('Xuất PDF'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.download_for_offline, color: Colors.green),
                  label: const Text('Xuất Excel (.xlsx)'),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 20),

        Expanded(
          child: Card(
            color: Colors.white,
            child: ListView(
              children: [
                DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                  columns: const [
                    DataColumn(label: Text('Ngày chấm', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nhân viên', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check-In', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check-Out', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    DataRow(cells: [
                      const DataCell(Text('08/06/2026')),
                      const DataCell(Text('Nguyễn Văn A')),
                      const DataCell(Text('07:55 AM')),
                      const DataCell(Text('17:05 PM')),
                      DataCell(Chip(label: const Text('Đúng giờ'), backgroundColor: Colors.green[100], side: BorderSide.none)),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('08/06/2026')),
                      const DataCell(Text('Trần Thị B')),
                      const DataCell(Text('08:24 AM')),
                      const DataCell(Text('--:--')),
                      DataCell(Chip(label: const Text('Đi muộn'), backgroundColor: Colors.orange[100], side: BorderSide.none)),
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

class LeaveRequestsScreen extends StatelessWidget {
  const LeaveRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phê Duyệt Đơn Xin Nghỉ Phép', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
       
        Expanded(
          child: Card(
            color: Colors.white,
            child: ListView(
              children: [
                DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                  columns: const [
                    DataColumn(label: Text('Nhân viên', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Lý do xin nghỉ', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Khoảng thời gian', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Thao tác duyệt', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    DataRow(cells: [
                      const DataCell(Text('Lê Văn C')),
                      const DataCell(Text('Xin nghỉ ốm đi khám răng định kỳ')),
                      const DataCell(Text('09/06 đến 10/06')),
                      DataCell(Chip(label: const Text('Chờ xử lý'), backgroundColor: Colors.yellow[100], side: BorderSide.none)),
                      DataCell(Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            child: const Text('Duyệt'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            child: const Text('Từ chối'),
                          ),
                        ],
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


class CompanySettingsScreen extends StatelessWidget {
  const CompanySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thiết Lập Tọa Độ Văn Phòng & Bán Kính Định Vị', 
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),

            child: SingleChildScrollView(
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 500, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: null,
                            decoration: InputDecoration(
                              labelText: 'Tên địa điểm văn phòng', 
                              border: OutlineInputBorder()
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Tọa độ Vĩ độ (Latitude)', 
                              border: OutlineInputBorder(), 
                              hintText: 'Ví dụ: 10.762622'
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Tọa độ Kinh độ (Longitude)', 
                              border: OutlineInputBorder(), 
                              hintText: 'Ví dụ: 106.660172'
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Bán kính cho phép chấm công', 
                              border: OutlineInputBorder(), 
                              suffixText: 'Mét'
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo, 
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
                          ),
                          child: const Text('Lưu Thay Đổi Cấu Hình GPS'),
                        ),
                      ],
                    )
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