import 'package:flutter/material.dart';
import '../../../../features/attendance/domain/attendance_model.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/attendance_status_badges.dart';
import '../../../../shared/widgets/shift_chip.dart';

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
              return AttendanceRowContent(
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

class AttendanceRowContent extends StatelessWidget {
  final AttendanceModel record;
  final bool isLast;

  const AttendanceRowContent({super.key, required this.record, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final weekday = DateHelper.getWeekdayName(record.attendanceDate);
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
                    ShiftChip(shift: record.shift),
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
              AttendanceStatusBadges(attendance: record),
            ],
          ),
        ],
      ),
    );
  }
}
