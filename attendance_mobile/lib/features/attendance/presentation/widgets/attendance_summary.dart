import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class AttendanceSummary extends StatelessWidget {
  final int total;
  final int early;
  final int late;
  final int absent;

  const AttendanceSummary({
    super.key,
    required this.total,
    required this.early,
    required this.late,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        children: [
          Expanded(child: _SumBox(value: total, label: 'Ngày công', color: AppColors.primary)),
          const SizedBox(width: 6),
          Expanded(child: _SumBox(value: early, label: 'Đến sớm', color: const Color(0xFF185FA5))),
          const SizedBox(width: 6),
          Expanded(child: _SumBox(value: late, label: 'Đi muộn', color: const Color(0xFF854F0B))),
          const SizedBox(width: 6),
          Expanded(child: _SumBox(value: absent, label: 'Vắng', color: AppColors.error)),
        ],
      ),
    );
  }
}

class _SumBox extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _SumBox({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}