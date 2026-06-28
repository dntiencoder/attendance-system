import 'package:flutter/material.dart';
import '../../features/attendance/domain/attendance_model.dart';
import '../theme/app_colors.dart';

class AttendanceStatusBadges extends StatelessWidget {
  final AttendanceModel? attendance;

  const AttendanceStatusBadges({
    super.key,
    this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    if (attendance == null) {
      return _badge(
        'Chưa chấm công',
        AppColors.backgroundTertiary,
        AppColors.textSecondary,
      );
    }

    if (attendance!.checkIn == null) {
      return _badge(
        'Vắng',
        AppColors.backgroundTertiary,
        AppColors.textTertiary, // Màu xám đồng bộ với Absent
      );
    }

    final badges = <Widget>[];

    if (attendance!.isLate) {
      badges.add(
        _badge(
          'Đi muộn',
          const Color(0xFFFFF4F4), // Nền đỏ rất nhạt
          AppColors.primary,       // Chữ đỏ UMC
        ),
      );
    }

    if (attendance!.isEarlyLeave) {
      badges.add(
        _badge(
          'Về sớm',
          const Color(0xFFFFF7ED), // Nền cam rất nhạt
          AppColors.warning,       // Chữ cam đồng bộ với Stat
        ),
      );
    }

    if (badges.isEmpty) {
      if (attendance!.hasCheckedOut) {
        badges.add(
          _badge(
            'Hoàn thành',
            const Color(0xFFF0FDF4), // Nền xanh rất nhạt
            AppColors.success,       // Chữ xanh đồng bộ
          ),
        );
      } else {
        badges.add(
          _badge(
            'Đúng giờ',
            const Color(0xFFF0FDF4),
            AppColors.success,
          ),
        );
      }
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: badges,
    );
  }

  Widget _badge(
    String text,
    Color bg,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
