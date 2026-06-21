import 'package:flutter/material.dart';
import '../../../../features/auth/domain/user_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';

class HomeHeader extends StatelessWidget {
  final UserModel? user;
  final String departmentName;

  const HomeHeader({
    super.key,
    this.user,
    this.departmentName = '',
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['Thứ Hai','Thứ Ba','Thứ Tư','Thứ Năm','Thứ Sáu','Thứ Bảy','Chủ Nhật'];
    final weekday = weekdays[now.weekday - 1];
    final dateStr = '$weekday, ${now.day.toString().padLeft(2,'0')}/${now.month.toString().padLeft(2,'0')}/${now.year}';

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        52,
        AppSpacing.md,
        28,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withValues(alpha:0.25),
                backgroundImage: (user?.avatarUrl.isNotEmpty ?? false)
                    ? NetworkImage(user!.avatarUrl)
                    : null,
                child: (user?.avatarUrl.isEmpty ?? true)
                    ? Text(
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              // Tên
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào,',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha:0.8),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      user?.name ?? '...',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Logo UMC
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                child: Image.network(
                  'https://umcvietnam.vn/wp-content/uploads/2024/04/Group-2.png',
                  height: 22,
                  errorBuilder: (_, __, ___) => const Text(
                    'UMC',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Bell
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.white,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Date + department
          Row(
            children: [
              Icon(Icons.calendar_today,
                  color: AppColors.white.withValues(alpha:0.75), size: 13),
              const SizedBox(width: 5),
              Text(
                departmentName.isNotEmpty
                    ? '$dateStr · $departmentName'
                    : dateStr,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha:0.75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}