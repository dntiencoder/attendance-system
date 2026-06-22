import 'package:flutter/material.dart';
import '../../../../features/attendance/domain/attendance_model.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../shared/theme/app_colors.dart';

class AttendanceRecordList extends StatelessWidget {
  final List<AttendanceModel> records;

  const AttendanceRecordList({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    // Nhóm theo tuần
    final groups = <String, List<AttendanceModel>>{};
    for (final r in records) {
      final key = _weekLabel(r.attendanceDate);
      groups.putIfAbsent(key, () => []).add(r);
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: groups.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ...entry.value.map((r) => _RecordCard(record: r)),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }

  String _weekLabel(DateTime date) {
    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));

    if (date.isAfter(startOfThisWeek.subtract(const Duration(days: 1)))) {
      return 'Tuần này';
    } else if (date.isAfter(startOfLastWeek.subtract(const Duration(days: 1)))) {
      return 'Tuần trước';
    } else {
      return 'Tuần ${_weekNumber(date)}/${date.month}';
    }
  }

  int _weekNumber(DateTime date) {
    return ((date.day - 1) / 7).floor() + 1;
  }
}

class _RecordCard extends StatelessWidget {
  final AttendanceModel record;

  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final isAbsent = record.checkIn == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAbsent ? const Color(0xFFFCEBEB) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ngày + ca
                Row(
                  children: [
                    Text(
                      _weekdayName(record.attendanceDate),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _ShiftChip(shift: record.shift),
                  ],
                ),
                const SizedBox(height: 3),

                // Giờ vào/ra
                if (!isAbsent) ...[
                  Text(
                    '${_timeOrDash(record.checkIn)}  →  ${_timeOrDash(record.checkOut)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cách CT: ${record.distance.toStringAsFixed(0)}m'
                        '${record.hasCheckedOut ? ' · ${record.calculatedWorkHours.toStringAsFixed(1)} giờ' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else
                  const Text(
                    'Chưa chấm công',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
          _StatusBadge(record: record),
        ],
      ),
    );
  }

  String _weekdayName(DateTime date) {
    const days = ['Thứ Hai','Thứ Ba','Thứ Tư','Thứ Năm','Thứ Sáu','Thứ Bảy','Chủ Nhật'];
    return '${days[date.weekday - 1]}, ${DateHelper.toDisplayDate(date)}';
  }

  String _timeOrDash(DateTime? dt) =>
      dt != null ? DateHelper.toTimeString(dt) : '--:--';
}

class _ShiftChip extends StatelessWidget {
  final String shift;
  const _ShiftChip({required this.shift});

  @override
  Widget build(BuildContext context) {
    final isDay = shift == 'day';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: isDay ? const Color(0xFFFFF4F4) : const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isDay ? 'Ngày' : 'Đêm',
        style: TextStyle(
          fontSize: 10,
          color: isDay ? AppColors.primary : const Color(0xFF185FA5),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AttendanceModel record;
  const _StatusBadge({required this.record});

  @override
  Widget build(BuildContext context) {
    if (record.checkIn == null) {
      return _badge('Vắng', const Color(0xFFFCEBEB), const Color(0xFF791F1F));
    }
    if (record.isLate && record.isEarlyLeave) {
      return _badge('Muộn & sớm', const Color(0xFFFCEBEB), AppColors.error);
    }
    if (record.isLate) {
      return _badge('Đi muộn', const Color(0xFFFAEEDA), const Color(0xFF633806));
    }
    if (record.isEarlyLeave) {
      return _badge('Về sớm', const Color(0xFFE6F1FB), const Color(0xFF0C447C));
    }
    return _badge('Đúng giờ', const Color(0xFFEAF3DE), const Color(0xFF27500A));
  }

  Widget _badge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}