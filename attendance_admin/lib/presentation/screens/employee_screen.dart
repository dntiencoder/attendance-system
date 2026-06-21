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