import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/employee_model.dart';
import 'employee_provider.dart';
import '../../department/domain/department_model.dart'; // Thêm model này
import '../../department/presentation/department_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/utils/app_logger.dart';

/// Sinh mật khẩu ngẫu nhiên đủ mạnh cho tài khoản nhân viên mới. Loại bỏ các
/// ký tự dễ đọc nhầm (I/l/O/0/1) vì admin cần đọc/gõ lại để báo cho nhân viên.
String _generateRandomPassword({int length = 10}) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';
  final random = Random.secure();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}

class EmployeeScreen extends ConsumerWidget {
  const EmployeeScreen({super.key});

  void _showEmployeeDialog(BuildContext context, WidgetRef ref, {EmployeeModel? employee}) {
    final isEditing = employee != null;
    final codeController = TextEditingController(text: employee?.employeeCode ?? '');
    final nameController = TextEditingController(text: employee?.name ?? '');
    final emailController = TextEditingController(text: employee?.email ?? '');
    final phoneController = TextEditingController(text: employee?.phone ?? '');
    final avatarController = TextEditingController(text: employee?.avatarUrl ?? '');
    final passwordController = TextEditingController(text: _generateRandomPassword());
    
    // Lấy danh sách phòng ban từ Provider (lấy thông qua ref.read để tránh watch trong function)
    final departmentsAsync = ref.read(departmentsStreamProvider);

    String selectedShiftGroup = employee?.shiftGroup ?? 'A';
    String selectedDeptId = employee?.departmentId ?? '';
    
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit_note_rounded : Icons.person_add_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(isEditing ? 'Sửa Thông Tin Nhân Viên' : 'Thêm Nhân Viên Mới', 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 550,
                child: Form(
                  key: dialogFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: codeController,
                                decoration: const InputDecoration(labelText: 'Mã nhân viên', border: OutlineInputBorder()),
                                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: nameController,
                                decoration: const InputDecoration(labelText: 'Họ và tên', border: OutlineInputBorder()),
                                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Địa chỉ Email', border: OutlineInputBorder()),
                          validator: Validators.email,
                          enabled: !isEditing, 
                        ),
                        if (!isEditing) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: passwordController,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu đăng nhập (đã sinh tự động, có thể sửa)',
                              border: const OutlineInputBorder(),
                              hintText: 'Hãy sao chép để gửi cho nhân viên',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.refresh_rounded),
                                tooltip: 'Sinh mật khẩu mới',
                                onPressed: () => setState(
                                  () => passwordController.text = _generateRandomPassword(),
                                ),
                              ),
                            ),
                            validator: (v) => v == null || v.length < 6 ? 'Tối thiểu 6 ký tự' : null,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: phoneController,
                                decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
                                validator: (v) => (v == null || v.trim().isEmpty) ? null : Validators.phone(v),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: departmentsAsync.when(
                                data: (depts) {
                                  // Nếu chưa chọn hoặc ID không tồn tại trong list mới
                                  if (selectedDeptId.isEmpty || !depts.any((d) => d.id == selectedDeptId)) {
                                    if (depts.isNotEmpty) selectedDeptId = depts.first.id;
                                  }

                                  return DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: selectedDeptId.isNotEmpty ? selectedDeptId : null,
                                    decoration: const InputDecoration(labelText: 'Phòng ban', border: OutlineInputBorder()),
                                    items: depts.map((d) => DropdownMenuItem(
                                      value: d.id,
                                      child: Text(
                                        d.name,
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )).toList(),
                                    onChanged: (v) => setState(() => selectedDeptId = v!),
                                  );
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (_, _) => const Text('Lỗi tải phòng ban'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedShiftGroup,
                                decoration: const InputDecoration(labelText: 'Ca làm việc', border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'A', child: Text('Ca A')),
                                  DropdownMenuItem(value: 'B', child: Text('Ca B')),
                                ],
                                onChanged: (v) => setState(() => selectedShiftGroup = v!),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: avatarController,
                          decoration: const InputDecoration(labelText: 'Link ảnh đại diện (URL)', border: OutlineInputBorder()),
                        ),
                      ],
                    ),
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
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final updatedEmployee = EmployeeModel(
                          id: employee?.id ?? '',
                          employeeCode: codeController.text,
                          name: nameController.text,
                          email: emailController.text.trim(),
                          role: 'employee',
                          shiftGroup: selectedShiftGroup,
                          departmentId: selectedDeptId,
                          phone: phoneController.text,
                          avatarUrl: avatarController.text,
                          isActive: employee?.isActive ?? true,
                          createdAt: employee?.createdAt,
                        );
                        
                        final createdPassword = passwordController.text;

                        if (isEditing) {
                          await ref.read(employeeRepositoryProvider).updateEmployee(updatedEmployee);
                        } else {
                          await ref.read(employeeRepositoryProvider).addEmployee(
                            updatedEmployee,
                            createdPassword
                          );
                        }

                        if (context.mounted) {
                          Navigator.pop(context); // Tắt loading
                          Navigator.pop(context); // Tắt form
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Cập nhật thành công!'
                                    : 'Đã tạo tài khoản thành công! Mật khẩu: $createdPassword',
                              ),
                              duration: isEditing
                                  ? const Duration(seconds: 4)
                                  : const Duration(seconds: 15),
                              action: isEditing
                                  ? null
                                  : SnackBarAction(
                                      label: 'Sao chép',
                                      onPressed: () => Clipboard.setData(
                                        ClipboardData(text: createdPassword),
                                      ),
                                    ),
                            ),
                          );
                        }
                      } catch (e, st) {
                        AppLogger.error('EmployeeScreen.saveEmployee', e, st);
                        if (context.mounted) {
                          Navigator.pop(context); // Tắt loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.save_rounded),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  label: Text(isEditing ? 'Cập nhật' : 'Lưu & Tạo Auth'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesStreamProvider);
    final departmentsAsync = ref.watch(departmentsStreamProvider);

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
              onPressed: () => _showEmployeeDialog(context, ref),
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
              side: const BorderSide(color: AppColors.border),
            ),
            child: employeesAsync.when(
              loading: () => const LoadingWidget(message: 'Đang tải danh sách...'),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
              data: (employees) => SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Mã NV', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Họ Tên', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Phòng ban', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Ca', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: employees.map((emp) {
                    return DataRow(cells: [
                      DataCell(Text(emp.employeeCode)),
                      DataCell(Text(emp.name)),
                      DataCell(departmentsAsync.when(
                        data: (depts) {
                          final dept = depts.firstWhere((d) => d.id == emp.departmentId, orElse: () => DepartmentModel(id: '', name: emp.departmentId));
                          return Text(dept.name);
                        },
                        loading: () => const Text('...'),
                        error: (_, _) => Text(emp.departmentId),
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: emp.shiftGroup == 'A' ? Colors.blue.withValues(alpha: 0.1) : Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Ca ${emp.shiftGroup}',
                          style: TextStyle(
                            color: emp.shiftGroup == 'A' ? Colors.blue[800] : Colors.purple[800],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            onPressed: () => _showEmployeeDialog(context, ref, employee: emp),
                          ),
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

  Future<void> _showDeleteConfirm(BuildContext context, WidgetRef ref, EmployeeModel emp) async {
    // Chỉ cho phép xoá hồ sơ nhân viên CHƯA từng phát sinh dữ liệu nghiệp vụ
    // (Attendance/Leave Request) — độc lập với isActive. Xem thiết kế đầy đủ ở
    // docs/design/EMPLOYEE_LIFECYCLE.md và quyết định D-012 ở
    // docs/decision/01_DECISION_LOG.md. Xoá vẫn không xoá được tài khoản
    // Firebase Auth tương ứng (cần Admin SDK/Cloud Function, ngoài phạm vi —
    // xem OOS-07 ở docs/project/01_BACKLOG.md), nhưng đây không còn là rủi ro
    // chính cần chặn — rủi ro chính là phá dữ liệu chấm công/nghỉ phép thật.
    final hasBusinessData =
        await ref.read(employeeRepositoryProvider).hasBusinessData(emp.id);

    if (!context.mounted) return;

    if (hasBusinessData) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Không thể xoá'),
          content: const Text(
            'Không thể xoá nhân viên đã có dữ liệu chấm công hoặc đơn nghỉ phép.\n'
            'Nếu nhân viên đã nghỉ việc, hãy vô hiệu hoá tài khoản (nút bật/tắt) '
            'thay vì xoá — dữ liệu chấm công/lương của họ vẫn cần được giữ lại.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
          ],
        ),
      );
      return;
    }

    if (!context.mounted) return;

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Xác nhận xóa',
      message:
          'Bạn có chắc chắn muốn xóa nhân viên ${emp.name}?\n\n'
          'Xoá hồ sơ này sẽ không thể hoàn tác. Email "${emp.email}" đã dùng cho '
          'tài khoản này sẽ không thể dùng lại để tạo nhân viên mới sau khi xoá.',
      confirmLabel: 'Xóa',
      isDanger: true,
    );

    if (confirmed && context.mounted) {
      await ref.read(employeeRepositoryProvider).deleteEmployee(emp.id);
    }
  }
}
