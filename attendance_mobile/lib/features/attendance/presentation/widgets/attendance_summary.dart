import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/stat_overview.dart';

class AttendanceSummary extends StatelessWidget {
  final int onTime;
  final int early;
  final int late;
  final int absent;

  const AttendanceSummary({
    super.key,
    required this.onTime,
    required this.early,
    required this.late,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {
    return StatOverview(
      onTimeDays: onTime,
      earlyDays: early,
      lateDays: late,
      absentDays: absent,
      absentLabel: 'Vắng mặt',
      backgroundColor: AppColors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
    );
  }
}
