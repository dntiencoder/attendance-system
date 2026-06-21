import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/employee_model.dart';
import 'employee_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';

class EmployeeScreen extends ConsumerWidget {
  const EmployeeScreen({super.key});

  void _showAddEmployeeDialog(BuildContext context, WidgetRef ref) {
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
              Icon(Icons.person_add_rounded, color: AppColors.primary),
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
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Mã nhân viên', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập mã' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Họ và tên', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Địa chỉ Email', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập email' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Quyền hạn', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Employee', child: Text('Employee')),
                      DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                    ],
                    onChanged: (v) {
                      if (v != null) selectedRole = v;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (dialogFormKey.currentState!.validate()) {
                  final newEmployee = EmployeeModel(
                    id: '',
                    employeeCode: codeController.text,
                    name: nameController.text,
                    email: emailController.text,
                    role: selectedRole.toLowerCase(),
                  );
                  await ref.read(employeeRepositoryProvider).addEmployee(newEmployee);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save_rounded),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              label: const Text('Lưu lại'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.badge_rounded, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Danh Sách Hồ Sơ Nhân Sự UMC',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddEmployeeDialog(context, ref),
              icon: const Icon(Icons.add_circle_outline_rounded),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              label: const Text('Thêm Nhân Viên Mới'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.border),
            ),
            child: employeesAsync.when(
              loading: () => const LoadingWidget(message: 'Đang tải danh sách...'),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
              data: (employees) => SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Mã NV', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Họ Tên', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Quyền hạn', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: employees.map((emp) {
                    return DataRow(cells: [
                      DataCell(Text(emp.employeeCode)),
                      DataCell(Text(emp.name)),
                      DataCell(Text(emp.email)),
                      DataCell(Text(emp.role)),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              emp.isActive ? Icons.toggle_on : Icons.toggle_off,
                              color: emp.isActive ? Colors.green : Colors.grey,
                            ),
                            onPressed: () => ref
                                .read(employeeRepositoryProvider)
                                .toggleStatus(emp.id, emp.isActive),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _showDeleteConfirm(context, ref, emp),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, EmployeeModel emp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa nhân viên ${emp.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              await ref.read(employeeRepositoryProvider).deleteEmployee(emp.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
