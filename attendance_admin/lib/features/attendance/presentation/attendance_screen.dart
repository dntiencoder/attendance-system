import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'attendance_provider.dart';
import '../domain/attendance_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/status_badge.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.assignment_turned_in_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Nhật Ký Chấm Công Toàn Cầu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                _buildExportButton(Icons.picture_as_pdf_rounded, 'PDF', Colors.red),
                const SizedBox(width: 12),
                _buildExportButton(Icons.grid_on_rounded, 'Excel', Colors.green),
              ],
            )
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
            child: attendanceAsync.when(
              loading: () => const LoadingWidget(message: 'Đang tải nhật ký...'),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
              data: (logs) => SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.background),
                  columns: const [
                    DataColumn(label: Text('Ngày', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nhân viên', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Ca', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check-In', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check-Out', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Khoảng cách', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: logs.map((log) {
                    return DataRow(cells: [
                      DataCell(Text(log.attendanceDate != null ? DateHelper.toDisplayDate(log.attendanceDate!) : '-')),
                      DataCell(Text(log.employeeCode, style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(_buildShiftBadge(log.shift)),
                      DataCell(Text(log.checkIn != null ? DateHelper.toTimeString(log.checkIn!) : '-')),
                      DataCell(Text(log.checkOut != null ? DateHelper.toTimeString(log.checkOut!) : '-')),
                      DataCell(Text(_formatDistance(log.distance))),
                      DataCell(_buildStatusBadge(log)),
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

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)}km';
    }
    return '${meters.toStringAsFixed(1)}m';
  }

  Widget _buildExportButton(IconData icon, String label, Color color) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: color, size: 18),
      label: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildShiftBadge(String shift) {
    final isDay = shift.toLowerCase() == 'day';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDay ? Colors.orange.withValues(alpha: 0.1) : Colors.indigo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isDay ? 'Sáng' : 'Đêm',
        style: TextStyle(
          color: isDay ? Colors.orange[800] : Colors.indigo[800],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AttendanceModel log) {
    Color color;
    String text;

    if (log.isLate && log.isEarlyLeave) {
      color = Colors.purple;
      text = 'Muộn & Về sớm';
    } else if (log.isLate) {
      color = Colors.orange;
      text = 'Đi muộn';
    } else if (log.isEarlyLeave) {
      color = Colors.blue;
      text = 'Về sớm';
    } else if (log.status == 'on_time' || log.status == 'completed') {
      color = Colors.green;
      text = 'Đúng giờ';
    } else {
      color = Colors.grey;
      text = log.status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
