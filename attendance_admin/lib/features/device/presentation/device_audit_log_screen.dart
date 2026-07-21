import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../employee/presentation/employee_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';
import 'device_audit_log_provider.dart';

/// FEAT-05 — màn xem lịch sử thiết bị theo từng nhân viên, đóng vai trò
/// Activation History (chỉ là 1 cách trình bày lọc trên `device_audit_log`,
/// không phải collection riêng — xem docs/design/ANTI_FRAUD_DESIGN.md §6).
class DeviceAuditLogScreen extends ConsumerStatefulWidget {
  const DeviceAuditLogScreen({super.key});

  @override
  ConsumerState<DeviceAuditLogScreen> createState() =>
      _DeviceAuditLogScreenState();
}

class _DeviceAuditLogScreenState extends ConsumerState<DeviceAuditLogScreen> {
  String? _selectedUid;

  static const _eventLabels = {
    'code_issued': 'Cấp mã kích hoạt',
    'activated': 'Kích hoạt thiết bị',
    'admin_reset': 'Admin thu hồi thiết bị',
    'code_expired': 'Mã hết hạn',
    'code_locked': 'Mã bị khoá',
  };

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.phonelink_lock_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Lịch Sử Thiết Bị',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        employeesAsync.when(
          loading: () => const LoadingWidget(message: 'Đang tải danh sách...'),
          error: (err, st) => const Text('Không thể tải danh sách nhân viên.'),
          data: (employees) => SizedBox(
            width: 320,
            child: DropdownButtonFormField<String>(
              initialValue: _selectedUid,
              decoration: const InputDecoration(
                labelText: 'Chọn nhân viên',
                border: OutlineInputBorder(),
              ),
              items: employees
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.id,
                      child: Text('${e.employeeCode} — ${e.name}'),
                    ),
                  )
                  .toList(),
              onChanged: (uid) => setState(() => _selectedUid = uid),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _selectedUid == null
              ? const Center(child: Text('Chọn 1 nhân viên để xem lịch sử thiết bị.'))
              : _buildLogTable(_selectedUid!),
        ),
      ],
    );
  }

  Widget _buildLogTable(String uid) {
    final logsAsync = ref.watch(deviceAuditLogProvider(uid));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: logsAsync.when(
        loading: () => const LoadingWidget(message: 'Đang tải lịch sử...'),
        error: (err, st) => const Center(child: Text('Không thể tải lịch sử thiết bị.')),
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('Nhân viên này chưa có lịch sử thiết bị.'));
          }
          return SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Thời gian', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Sự kiện', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Thực hiện bởi', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Lý do', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: logs.map((log) {
                return DataRow(cells: [
                  DataCell(Text(DateFormat('dd/MM/yyyy HH:mm').format(log.timestamp))),
                  DataCell(Text(_eventLabels[log.eventType] ?? log.eventType)),
                  DataCell(Text(log.actorRole == 'admin' ? 'Admin' : 'Nhân viên')),
                  DataCell(Text(log.reason ?? '-')),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
