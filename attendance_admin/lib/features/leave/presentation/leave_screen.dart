import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'leave_provider.dart';
import '../domain/leave_request_model.dart';
import '../../../core/utils/date_helper.dart';
import '../../../shared/widgets/loading_widget.dart';

class LeaveScreen extends ConsumerWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaveRequestsAsync = ref.watch(leaveRequestsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.rate_review_rounded, color: Color(0xFFB91C1C)),
            SizedBox(width: 8),
            Text('Phê Duyệt Đơn Xin Nghỉ Phép',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: leaveRequestsAsync.when(
              loading: () => const LoadingWidget(message: 'Đang tải danh sách...'),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
              data: (requests) => requests.isEmpty
                  ? const Center(child: Text('Không có yêu cầu nghỉ phép nào.'))
                  : SingleChildScrollView(
                      child: DataTable(
                        headingRowColor:
                            WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        columns: const [
                          DataColumn(
                              label: Text('Mã NV',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Lý do xin nghỉ',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Thời gian',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Số ngày',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Trạng thái',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Thao tác',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: requests.map((req) {
                          return DataRow(cells: [
                            DataCell(Text(req.employeeCode,
                                style: const TextStyle(fontWeight: FontWeight.w500))),
                            DataCell(Text(req.reason)),
                            DataCell(Text(
                                '${req.startDate != null ? DateHelper.toDisplayDate(req.startDate!) : '-'} - ${req.endDate != null ? DateHelper.toDisplayDate(req.endDate!) : '-'}')),
                            DataCell(Text('${req.totalDays}')),
                            DataCell(_buildStatusBadge(req.status)),
                            DataCell(req.isPending
                                ? Row(
                                    children: [
                                      IconButton(
                                          icon: const Icon(Icons.check_circle_rounded,
                                              color: Colors.green),
                                          onPressed: () => _showDecisionDialog(
                                              context, ref, req, 'approved')),
                                      IconButton(
                                          icon: const Icon(Icons.cancel_rounded,
                                              color: Colors.red),
                                          onPressed: () => _showDecisionDialog(
                                              context, ref, req, 'rejected')),
                                    ],
                                  )
                                : const Text('Đã xử lý',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 13))),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    Color bgColor;

    switch (status) {
      case 'approved':
        color = Colors.green;
        label = 'Đã duyệt';
        bgColor = const Color(0xFFDCFCE7);
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Từ chối';
        bgColor = const Color(0xFFFEE2E2);
        break;
      default:
        color = Colors.orange;
        label = 'Chờ xử lý';
        bgColor = const Color(0xFFFEF9C3);
    }

    return Chip(
      label: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, color: color)),
      backgroundColor: bgColor,
      side: BorderSide.none,
    );
  }

  void _showDecisionDialog(BuildContext context, WidgetRef ref,
      LeaveRequestModel req, String decision) {
    final noteController = TextEditingController();
    final isApproval = decision == 'approved';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApproval ? 'Duyệt đơn nghỉ phép' : 'Từ chối đơn nghỉ phép'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nhân viên: ${req.employeeCode}'),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú của Admin',
                border: OutlineInputBorder(),
                hintText: 'Nhập lý do hoặc phản hồi...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(leaveActionProvider.notifier).updateStatus(
                    req,
                    decision,
                    adminNote: noteController.text.trim(),
                  );
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproval ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isApproval ? 'Duyệt' : 'Từ chối'),
          ),
        ],
      ),
    );
  }
}
