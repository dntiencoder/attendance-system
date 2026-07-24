import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'attendance_provider.dart';
import '../domain/attendance_model.dart';
import '../../employee/presentation/employee_provider.dart';
import '../../employee/domain/employee_model.dart';
import '../../department/presentation/department_provider.dart';
import '../../settings/presentation/settings_provider.dart';
import '../../settings/domain/company_settings_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/rotation_calculator.dart';
import '../../../core/utils/work_schedule_helper.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/services/export_service.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String _searchQuery = '';
  DateTimeRange? _selectedRange;
  String? _selectedShift;
  String? _selectedStatusFilter;
  String? _selectedDepartmentId;

  /// Khoảng ân hạn Check Out muộn cho ca đêm — đồng bộ với
  /// `_checkOutGracePeriod` ở `attendance_mobile/.../attendance_repository.dart`
  /// (đã chốt ở docs/design/ATTENDANCE_BUSINESS_FLOW.md). Quá mốc này mà vẫn
  /// chưa Check Out thì coi là quên, không phải "đang làm việc" nữa.
  static const _checkOutGracePeriod = Duration(hours: 1);

  /// Record có `checkIn` nhưng chưa `checkOut`, và đã qua khỏi giờ tan ca +
  /// khoảng ân hạn từ lâu -- mirror `resolveShiftWindow()` của mobile
  /// (`business_date_helper.dart`), chỉ tính riêng cho 1 record đã biết sẵn
  /// `shift`/`attendanceDate`, không cần tới toàn bộ Business Date/rotation.
  bool _isForgottenCheckOut(AttendanceModel log, CompanySettingsModel settings) {
    if (log.hasCheckedOut || log.attendanceDate == null) return false;

    final date = log.attendanceDate!;
    final startParts = settings.getShiftStartTime(log.shift).split(':');
    final endParts = settings.getShiftEndTime(log.shift).split(':');

    final start = DateTime(
      date.year, date.month, date.day,
      int.parse(startParts[0]), int.parse(startParts[1]),
    );
    var end = DateTime(
      date.year, date.month, date.day,
      int.parse(endParts[0]), int.parse(endParts[1]),
    );
    if (!end.isAfter(start)) end = end.add(const Duration(days: 1));

    return DateTime.now().isAfter(end.add(_checkOutGracePeriod));
  }

  /// Phân loại trạng thái cho bộ lọc — khớp đúng logic đang dùng để hiển thị
  /// badge ở `_buildStatusBadge()`, không phải mọi log chỉ khớp đúng 1 loại
  /// (VD: Đi muộn + Hoàn thành có thể cùng đúng trên 1 log).
  bool _matchesStatusFilter(AttendanceModel log, String filter, CompanySettingsModel? settings) {
    switch (filter) {
      case 'absent':
        return log.status == 'absent';
      case 'in_progress':
        return !log.hasCheckedOut &&
            log.status != 'absent' &&
            !(settings != null && _isForgottenCheckOut(log, settings));
      case 'forgotten_checkout':
        return settings != null && _isForgottenCheckOut(log, settings);
      case 'completed':
        return log.hasCheckedOut && !log.isLate && !log.isEarlyLeave;
      case 'late':
        return log.isLate;
      case 'early_leave':
        return log.isEarlyLeave;
      default:
        return true;
    }
  }

  List<AttendanceModel> _applyFilters(
    List<AttendanceModel> logs,
    Map<String, String> uidToDepartmentId,
    CompanySettingsModel? settings,
  ) {
    return logs.where((log) {
      final matchesSearch =
          log.employeeCode.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesShift = _selectedShift == null || log.shift == _selectedShift;
      final matchesStatus = _selectedStatusFilter == null ||
          _matchesStatusFilter(log, _selectedStatusFilter!, settings);
      final matchesDepartment = _selectedDepartmentId == null ||
          uidToDepartmentId[log.uid] == _selectedDepartmentId;
      return matchesSearch && matchesShift && matchesStatus && matchesDepartment;
    }).toList();
  }

  /// Cùng công thức fallback (khoảng đã chọn, hoặc mặc định tháng hiện tại)
  /// mà `attendanceStreamProvider` dùng để tính start/end cho query Firestore
  /// -- cần biết đúng khoảng này để sinh dòng "Vắng mặt" ảo cho đúng số ngày.
  DateTimeRange _effectiveRange() {
    if (_selectedRange != null) return _selectedRange!;
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  /// Sinh dòng "Vắng mặt" ảo (không lưu Firestore, chỉ tồn tại để hiển thị)
  /// cho mỗi nhân viên đang hoạt động × mỗi ngày làm bắt buộc trong khoảng đã
  /// chọn mà không có document `attendance` thật -- mirror cách
  /// `attendance_history_provider.dart` (mobile) làm cho riêng 1 tài khoản,
  /// áp dụng cho toàn bộ nhân viên. Không sinh cho ngày tương lai (chưa tới
  /// hạn thì chưa thể coi là vắng).
  List<AttendanceModel> _generateAbsences({
    required List<AttendanceModel> realLogs,
    required List<EmployeeModel> employees,
    required CompanySettingsModel settings,
  }) {
    final rotationStartDate = settings.rotationStartDate;
    if (rotationStartDate == null) return [];

    final range = _effectiveRange();
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final lastDay = range.end.isAfter(todayNormalized) ? todayNormalized : range.end;
    if (lastDay.isBefore(range.start)) return [];

    final existingKeys = <String>{
      for (final log in realLogs)
        if (log.attendanceDate != null)
          '${log.uid}_${DateHelper.toDateString(log.attendanceDate!)}',
    };

    final virtual = <AttendanceModel>[];
    for (final employee in employees.where((e) => e.isActive)) {
      final joinedAt = employee.createdAt;
      final firstEligibleDay = joinedAt != null
          ? DateTime(joinedAt.year, joinedAt.month, joinedAt.day)
          : null;

      for (var day = range.start;
          !day.isAfter(lastDay);
          day = day.add(const Duration(days: 1))) {
        if (firstEligibleDay != null && day.isBefore(firstEligibleDay)) continue;
        if (!WorkScheduleHelper.isMandatoryWorkDay(day, rotationStartDate)) continue;

        final key = '${employee.id}_${DateHelper.toDateString(day)}';
        if (existingKeys.contains(key)) continue;

        final shift = RotationCalculator.getCurrentShift(
          rotationStartDate: rotationStartDate,
          rotationDays: settings.rotationDays,
          shiftGroup: employee.shiftGroup,
          date: day,
        );

        virtual.add(AttendanceModel(
          id: 'virtual_${employee.id}_${DateHelper.toDateString(day)}',
          uid: employee.id,
          employeeCode: employee.employeeCode,
          shift: shift,
          attendanceDate: day,
          status: 'absent',
        ));
      }
    }
    return virtual;
  }

  List<AttendanceModel> _withAbsences(
    List<AttendanceModel> logs,
    List<EmployeeModel> employees,
    CompanySettingsModel? settings,
  ) {
    if (settings == null) return logs;
    return [...logs, ..._generateAbsences(realLogs: logs, employees: employees, settings: settings)];
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(attendanceStreamProvider(_selectedRange));
    final employeesAsync = ref.watch(employeesStreamProvider);
    final departmentsAsync = ref.watch(departmentsStreamProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);

    final uidToDepartmentId = <String, String>{
      for (final e in employeesAsync.value ?? []) e.id: e.departmentId,
    };
    final departments = departmentsAsync.value ?? [];
    final settings = settingsAsync.value;

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
              data: (logs) {
                final enrichedLogs = _withAbsences(logs, employeesAsync.value ?? [], settings);
                final filteredLogs = _applyFilters(enrichedLogs, uidToDepartmentId, settings);
                return Row(
                  children: [
                    _buildExportButton(
                      Icons.picture_as_pdf_rounded,
                      'PDF',
                      Colors.red,
                      onPressed: () => ExportService.exportToPdf(filteredLogs),
                    ),
                    const SizedBox(width: 12),
                    _buildExportButton(
                      Icons.grid_on_rounded,
                      'Excel',
                      Colors.green,
                      onPressed: () => ExportService.exportToExcel(filteredLogs),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Filter Row
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 280,
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      initialDateRange: _selectedRange,
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (range != null) setState(() => _selectedRange = range);
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text(_selectedRange == null
                    ? 'Chọn khoảng ngày'
                    : '${DateHelper.toDisplayDate(_selectedRange!.start)} - ${DateHelper.toDisplayDate(_selectedRange!.end)}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                if (_selectedRange != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _selectedRange = null),
                  ),
              ],
            ),
          ],
        ),
        if (_selectedRange == null) ...[
          const SizedBox(height: 8),
          Text(
            'Đang hiển thị tháng ${DateTime.now().month}/${DateTime.now().year} — chọn khoảng ngày cụ thể để xem giai đoạn khác.',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedShift,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Ca làm',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Tất cả', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'day',
                    child: Text('Ca ngày', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'night',
                    child: Text('Ca đêm', overflow: TextOverflow.ellipsis),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedShift = value),
              ),
            ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedStatusFilter,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Tất cả', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'absent',
                    child: Text('Vắng mặt', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'in_progress',
                    child: Text('Đang làm việc', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'forgotten_checkout',
                    child: Text('Quên Check Out', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'completed',
                    child: Text('Hoàn thành', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'late',
                    child: Text('Đi muộn', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'early_leave',
                    child: Text('Về sớm', overflow: TextOverflow.ellipsis),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedStatusFilter = value),
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedDepartmentId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Phòng ban',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Tất cả', overflow: TextOverflow.ellipsis),
                  ),
                  ...departments.map(
                    (d) => DropdownMenuItem(
                      value: d.id,
                      child: Text(d.name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedDepartmentId = value),
              ),
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
              error: (err, st) {
                AppLogger.error('AttendanceScreen.load', err, st);
                return const Center(child: Text('Không thể tải nhật ký chấm công. Vui lòng thử lại.'));
              },
              data: (logs) {
                final enrichedLogs = _withAbsences(logs, employeesAsync.value ?? [], settings);
                final filteredLogs = _applyFilters(enrichedLogs, uidToDepartmentId, settings);

                return filteredLogs.isEmpty
                  ? const Center(child: Text('Không tìm thấy bản ghi nào.'))
                  : SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.background),
                        dataRowMinHeight: 48,
                        dataRowMaxHeight: 64,
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
                            DataCell(Text(log.checkIn == null ? '-' : _formatDistance(log.distance))),
                            DataCell(Text(log.hasCheckedOut ? '${log.calculatedWorkHours.toStringAsFixed(1)}h' : '-')),
                            DataCell(_buildStatusBadge(log, settings)),
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

  Widget _buildStatusBadge(AttendanceModel log, CompanySettingsModel? settings) {
    List<Widget> badges = [];

    // 1. Xác định trạng thái chính
    if (log.status == 'absent') {
      badges.add(_createBadge('Vắng mặt', AppColors.error));
    } else if (!log.hasCheckedOut) {
      if (settings != null && _isForgottenCheckOut(log, settings)) {
        badges.add(_createBadge('Quên Check Out', Colors.brown));
      } else {
        badges.add(_createBadge('Đang làm việc', Colors.blue));
      }
    } else if (!log.isLate && !log.isEarlyLeave) {
      badges.add(_createBadge('Hoàn thành', AppColors.success));
    }

    // 2. Các trạng thái vi phạm (hiển thị song song)
    if (log.isLate) {
      badges.add(_createBadge('Đi muộn', Colors.orange));
    }

    if (log.isEarlyLeave) {
      badges.add(_createBadge('Về sớm', Colors.deepOrange));
    }

    if (badges.isEmpty) {
      badges.add(_createBadge(log.statusLabel, Colors.grey));
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: badges,
    );
  }

  Widget _createBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
