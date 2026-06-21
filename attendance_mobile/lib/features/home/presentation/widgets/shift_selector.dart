import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';

class ShiftSelector extends StatelessWidget {
  final String selectedShift;
  final bool enabled;
  final ValueChanged<String> onShiftChanged;

  const ShiftSelector({
    super.key,
    required this.selectedShift,
    required this.onShiftChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn ca làm việc',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _ShiftButton(
                label: 'Ca ngày',
                subLabel: '08:00 – 20:00',
                icon: Icons.wb_sunny_outlined,
                isSelected: selectedShift == 'day',
                selectedColor: AppColors.primary,
                selectedBg: const Color(0xFFFFF4F4),
                onTap: enabled ? () => onShiftChanged('day') : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ShiftButton(
                label: 'Ca đêm',
                subLabel: '20:00 – 08:00',
                icon: Icons.nightlight_outlined,
                isSelected: selectedShift == 'night',
                selectedColor: const Color(0xFF185FA5),
                selectedBg: const Color(0xFFE6F1FB),
                onTap: enabled ? () => onShiftChanged('night') : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShiftButton extends StatelessWidget {
  final String label;
  final String subLabel;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final Color selectedBg;
  final VoidCallback? onTap;

  const _ShiftButton({
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedBg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? selectedColor : AppColors.textSecondary),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? selectedColor : AppColors.textSecondary,
              ),
            ),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? selectedColor.withValues(alpha:0.7)
                    : AppColors.textSecondary.withValues(alpha:0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}