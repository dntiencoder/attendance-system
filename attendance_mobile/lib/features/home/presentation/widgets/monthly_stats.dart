import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/section_title.dart';

class MonthlyStats extends StatelessWidget {
  final int total;
  final int early;
  final int late;
  final int leave;
  final DateTime month;

  const MonthlyStats({
    super.key,
    required this.total,
    required this.early,
    required this.late,
    required this.leave,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Thống kê tháng ${month.month.toString().padLeft(2,'0')}/${month.year}',
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: _StatBox(value: total, label: 'Ngày công', color: AppColors.primary)),
            const SizedBox(width: 6),
            Expanded(child: _StatBox(value: early, label: 'Về sớm', color: const Color(0xFF185FA5))),
            const SizedBox(width: 6),
            Expanded(child: _StatBox(value: late, label: 'Đi muộn', color: AppColors.warning)),
            const SizedBox(width: 6),
            Expanded(child: _StatBox(value: leave, label: 'Ngày nghỉ', color: AppColors.success)),
          ],
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}