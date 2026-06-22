import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../auth/domain/user_model.dart';

class ProfileInfoList extends StatelessWidget {
  final UserModel user;
  final String departmentName;

  const ProfileInfoList({
    super.key,
    required this.user,
    required this.departmentName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoItem(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.phone_outlined,
            label: 'Số điện thoại',
            value: user.phone.isNotEmpty ? user.phone : 'Chưa cập nhật',
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.business_outlined,
            label: 'Phòng ban',
            value: departmentName.isNotEmpty ? departmentName : user.departmentId,
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.work_outline,
            label: 'Chức vụ',
            value: user.role == 'admin' ? 'Quản trị viên' : 'Nhân viên',
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.calendar_today_outlined,
            label: 'Ngày tham gia',
            value: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 54,
      endIndent: 16,
      color: AppColors.border.withValues(alpha: 0.5),
    );
  }
}
