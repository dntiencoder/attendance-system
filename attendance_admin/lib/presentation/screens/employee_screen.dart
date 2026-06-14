import 'package:flutter/material.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  // Bộ lưu trữ danh sách động trong RAM của ứng dụng
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
      barrierDismissible: false, // Ép buộc người dùng phải chọn Lưu hoặc Hủy
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_add_alt_1_rounded, color: Colors.indigo),
              SizedBox(width: 10),
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
                  TextFormField(
                    controller: codeController,
                    validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng điền mã nhân viên' : null,
                    decoration: const InputDecoration(labelText: 'Mã nhân viên (Ví dụ: NV003)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng điền họ và tên' : null,
                    decoration: const InputDecoration(labelText: 'Họ và tên nhân viên', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Vui lòng điền email';
                      if (!v.contains('@')) return 'Định dạng email không hợp lệ';
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Địa chỉ Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Quyền hạn hệ thống', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Employee', child: Text('Nhân viên (Employee)')),
                      DropdownMenuItem(value: 'Manager', child: Text('Quản lý (Manager)')),
                      DropdownMenuItem(value: 'Admin', child: Text('Quản trị viên (Admin)')),
                    ],
                    onChanged: (v) { if (v != null) selectedRole = v; },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Giải phóng bộ nhớ của các Controller trước khi đóng
                codeController.dispose();
                nameController.dispose();
                emailController.dispose();
                Navigator.pop(context);
              }, 
              child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  // Đẩy dữ liệu thật vào danh sách để cập nhật giao diện DataTable
                  setState(() {
                    _employees.add({
                      'id': codeController.text.trim().toUpperCase(),
                      'name': nameController.text.trim(),
                      'email': emailController.text.trim(),
                      'role': selectedRole,
                    });
                  });

                  // TODO: Sau này nhúng dữ liệu vào Firestore:
                  // await FirebaseFirestore.instance.collection('users').doc(uid).set({...});
                  
                  codeController.dispose();
                  nameController.dispose();
                  emailController.dispose();
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật dữ liệu và lưu nhân viên thành công!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              child: const Text('Lưu thông tin'),
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
            const Text('Danh Sách Quản Lý Nhân Viên', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _showAddEmployeeDialog, // Bấm vào sẽ mở Dialog và Form hoạt động thực tế
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
                  rows: _employees.map((emp) {
                    return DataRow(cells: [
                      DataCell(Text(emp['id']!)),
                      DataCell(Text(emp['name']!)),
                      DataCell(Text(emp['email']!)),
                      DataCell(Text(emp['role']!)),
                      DataCell(Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red), 
                            onPressed: () {
                              // Chức năng xóa dòng hoạt động trực tiếp trên giao diện
                              setState(() {
                                _employees.remove(emp);
                              });
                            },
                          ),
                        ],
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