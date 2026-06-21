import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/theme/app_colors.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  // Map path → tiêu đề
  static const _titles = {
    '/dashboard': 'Dashboard',
    '/employees': 'Quản lý nhân viên',
    '/attendance': 'Quản lý chấm công',
    '/leave': 'Duyệt nghỉ phép',
    '/departments': 'Quản lý phòng ban',
    '/settings': 'Cài đặt hệ thống',
  };

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final title = _titles[path] ?? 'UMC Admin';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Admin info
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Text(
                  'A',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Administrator',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}