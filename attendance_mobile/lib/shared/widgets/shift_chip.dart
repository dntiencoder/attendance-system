import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ShiftChip extends StatelessWidget {
  final String shift;

  const ShiftChip({
    super.key,
    required this.shift,
  });

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
