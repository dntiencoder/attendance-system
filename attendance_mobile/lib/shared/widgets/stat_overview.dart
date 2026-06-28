import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatOverview extends StatelessWidget {
  final int lateDays;
  final int earlyDays;
  final int absentDays;
  final int onTimeDays;
  final String absentLabel;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const StatOverview({
    super.key,
    required this.lateDays,
    required this.earlyDays,
    required this.absentDays,
    required this.onTimeDays,
    this.absentLabel = 'Vắng mặt',
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: lateDays,
                  label: 'Đi muộn',
                  color: AppColors.primary,
                  icon: Icons.access_time_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  value: earlyDays,
                  label: 'Về sớm',
                  color: AppColors.warning,
                  icon: Icons.directions_run_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: absentDays,
                  label: absentLabel,
                  color: AppColors.textTertiary,
                  icon: Icons.calendar_month_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  value: onTimeDays,
                  label: 'Đúng giờ',
                  color: AppColors.success,
                  icon: Icons.check_circle_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Vertical Indicator - Clean & Rounded
          Positioned(
            left: 0,
            top: 12,
            bottom: 12,
            child: Container(
              width: 3.5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top: Value + Unit
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$value',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: color,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'buổi',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: color.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom: Icon + Label
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      Icon(icon, size: 12, color: color.withValues(alpha: 0.8)),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
