import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'attendance_provider.dart';
import '../domain/attendance_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/services/export_service.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String _searchQuery = '';
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
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
                SizedBox(width: 8),
                Text(
                  'Nhật Ký Chấm Công Toàn Cầu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            attendanceAsync.when(
              data: (logs) => Row(
                children: [
                  _buildExportButton(
                    Icons.picture_as_pdf_rounded, 
                    'PDF', 
                    Colors.red,
                    onPressed: () => ExportService.exportToPdf(logs),
                  ),
                  const SizedBox(width: 12),
                  _buildExportButton(
                    Icons.grid_on_rounded, 
                    'Excel', 
                    Colors.green,
                    onPressed: () => ExportService.exportToExcel(logs),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Filter Row
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm theo mã nhân viên...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(_selectedDate == null
                ? 'Chọn ngày'
                : DateHelper.toDisplayDate(_selectedDate!)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            if (_selectedDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _selectedDate = null),
              ),
          ],
        ),
        const SizedBox(height: 16),
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
              data: (logs) {
                final filteredLogs = logs.where((log) {
                  final matchesSearch = log.employeeCode.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesDate = _selectedDate == null ||
                      (log.attendanceDate != null &&
                       DateHelper.isSameDay(log.attendanceDate!, _selectedDate!));
                  return matchesSearch && matchesDate;
                }).toList();

                return filteredLogs.isEmpty
                  ? const Center(child: Text('Không tìm thấy bản ghi nào.'))
                  : SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.background),
                        columns: const [
                          DataColumn(label: Text('Ngày', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Mã NV', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Ca làm', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Check-In', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Check-Out', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Khoảng cách', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Giờ làm', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredLogs.map((log) {
                          return DataRow(cells: [
                            DataCell(Text(log.attendanceDate != null ? DateHelper.toDisplayDate(log.attendanceDate!) : '-')),
                            DataCell(Text(log.employeeCode, style: const TextStyle(fontWeight: FontWeight.w500))),
                            DataCell(_buildShiftBadge(log.shift)),
                            DataCell(Text(log.checkIn != null ? DateHelper.toTimeString(log.checkIn!) : '-')),
                            DataCell(Text(log.checkOut != null ? DateHelper.toTimeString(log.checkOut!) : '-')),
                            DataCell(Text(_formatDistance(log.distance))),
                            DataCell(Text(log.hasCheckedOut ? '${log.calculatedWorkHours.toStringAsFixed(1)}h' : '-')),
                            DataCell(_buildStatusBadge(log)),
                          ]);
                        }).toList(),
                      ),
                    );
              },
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

  Widget _buildExportButton(IconData icon, String label, Color color, {required VoidCallback onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
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
    List<Widget> badges = [];

    // 1. Xác định trạng thái nền tảng
    if (log.status == 'absent') {
      badges.add(_createBadge('Vắng mặt', Colors.red));
    } else if (!log.hasCheckedOut) {
      // Nếu chưa check-out
      if (log.isLate) {
        badges.add(_createBadge('Đang làm việc', Colors.blueGrey));
      } else {
        badges.add(_createBadge('Đang làm việc', Colors.blue));
      }
    } else if (!log.isLate && !log.isEarlyLeave) {
      // Nếu đã check-out và không vi phạm gì
      badges.add(_createBadge('Hoàn thành', Colors.green));
    }

    // 2. Luôn hiển thị badge vi phạm (nếu có) - Độc lập với trạng thái nền
    if (log.isLate) {
      if (badges.isNotEmpty) badges.add(const SizedBox(width: 4));
      badges.add(_createBadge('Đi muộn', Colors.orange));
    }

    if (log.isEarlyLeave) {
      if (badges.isNotEmpty) badges.add(const SizedBox(width: 4));
      badges.add(_createBadge('Về sớm', Colors.deepOrange));
    }

    // Trường hợp dự phòng nếu không rơi vào các điều kiện trên
    if (badges.isEmpty) {
      badges.add(_createBadge(log.statusLabel, Colors.grey));
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: badges,
    );
  }

  Widget _createBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
