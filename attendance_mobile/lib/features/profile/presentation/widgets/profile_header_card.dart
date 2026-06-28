import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../auth/domain/user_model.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserModel user;
  final String departmentName;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.departmentName,
  });

  @override
  Widget build(BuildContext context) {
    // Tên viết tắt cho avatar nếu không có ảnh
    final initial = user.name.isNotEmpty ? user.name.split(' ').last[0].toUpperCase() : '?';

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.of(context).padding.top + 20,
        AppSpacing.md,
        18,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hồ sơ cá nhân',
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(height: 12),
          // Avatar wrap
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.22),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.55),
                    width: 2.5,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: user.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  child: user.avatarUrl.isEmpty
                      ? Text(
                          initial,
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.name,
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 2),
          Text(
            '${user.employeeCode} · ${departmentName.isNotEmpty ? departmentName : user.departmentId}',
            style: AppTextStyles.caption.copyWith(color: AppColors.white.withValues(alpha: 0.72)),
          ),
        ],
      ),
    );
  }
}
