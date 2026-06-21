import 'package:flutter/material.dart';
import '../../../../features/attendance/domain/attendance_model.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/section_title.dart';

class RecentAttendance extends StatelessWidget {
  final List<AttendanceModel> records;

  const RecentAttendance({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Chấm công gần đây'),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: records.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Center(
              child: Text(
                'Chưa có dữ liệu chấm công',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
              : Column(
            children: records.asMap().entries.map((entry) {
              return _AttendanceRow(
                record: entry.value,
                isLast: entry.key == records.length - 1,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final AttendanceModel record;
  final bool isLast;

  const _AttendanceRow({required this.record, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Thứ Hai','Thứ Ba','Thứ Tư','Thứ Năm','Thứ Sáu','Thứ Bảy','Chủ Nhật'];
    final weekday = weekdays[record.attendanceDate.weekday - 1];
    final dateStr = '$weekday, ${DateHelper.toDisplayDate(record.attendanceDate)}';
    final checkInStr = record.checkIn != null
        ? DateHelper.toTimeString(record.checkIn!) : '--:--';
    final checkOutStr = record.checkOut != null
        ? DateHelper.toTimeString(record.checkOut!) : '--:--';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _ShiftChip(shift: record.shift),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  record.employeeCode,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$checkInStr – $checkOutStr',
                style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 3),
              _StatusBadge(record: record),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShiftChip extends StatelessWidget {
  final String shift;
  const _ShiftChip({required this.shift});

  @override
  Widget build(BuildContext context) {
    final isDay = shift == 'day';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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
    final badges = <Widget>[];

    if (record.isLate) {
      badges.add(_badge('Đi muộn', const Color(0xFFFAEEDA), const Color(0xFF633806)));
    }
    if (record.isEarlyLeave) {
      badges.add(_badge('Về sớm', const Color(0xFFFFE6E6), AppColors.error));
    }

    if (badges.isEmpty) {
      if (record.hasCheckedOut) {
        badges.add(_badge('Hoàn thành', const Color(0xFFE6F1FB), const Color(0xFF0C447C)));
      } else {
        badges.add(_badge('Đúng giờ', const Color(0xFFEAF3DE), AppColors.success));
      }
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: badges,
    );
  }

  Widget _badge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}