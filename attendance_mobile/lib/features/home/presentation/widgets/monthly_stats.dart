import 'package:flutter/material.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/stat_overview.dart';

class MonthlyStats extends StatelessWidget {
  final int onTimeDays;
  final int earlyDays;
  final int lateDays;
  final int absentDays;
  final DateTime month;

  const MonthlyStats({
    super.key,
    required this.onTimeDays,
    required this.earlyDays,
    required this.lateDays,
    required this.absentDays,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Thống kê tháng ${month.month.toString().padLeft(2, '0')}/${month.year}',
        ),
        const SizedBox(height: AppSpacing.sm),
        StatOverview(
          onTimeDays: onTimeDays,
          earlyDays: earlyDays,
          lateDays: lateDays,
          absentDays: absentDays,
          absentLabel: 'Vắng mặt',
        ),
      ],
    );
  }
}
