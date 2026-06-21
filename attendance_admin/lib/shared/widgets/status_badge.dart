import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../core/constants/app_config.dart';

enum BadgeVariant { success, warning, error, neutral, info }

/// Badge hiển thị trạng thái dạng pill bo tròn. Dùng factory có sẵn cho các
/// trạng thái phổ biến (nghỉ phép, hoạt động) hoặc khởi tạo trực tiếp.
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;

  const StatusBadge({
    super.key,
    required this.label,
    required this.variant,
  });

  factory StatusBadge.leaveStatus(String status) {
    switch (status) {
      case AppConfig.statusApproved:
        return const StatusBadge(label: 'Đã duyệt', variant: BadgeVariant.success);
      case AppConfig.statusRejected:
        return const StatusBadge(label: 'Từ chối', variant: BadgeVariant.error);
      case AppConfig.statusPending:
      default:
        return const StatusBadge(label: 'Chờ duyệt', variant: BadgeVariant.warning);
    }
  }

  factory StatusBadge.activeStatus(bool isActive) {
    return StatusBadge(
      label: isActive ? 'Đang hoạt động' : 'Ngừng hoạt động',
      variant: isActive ? BadgeVariant.success : BadgeVariant.neutral,
    );
  }

  Color get _bgColor {
    switch (variant) {
      case BadgeVariant.success:
        return AppColors.success.withValues(alpha: 0.1);
      case BadgeVariant.warning:
        return AppColors.warning.withValues(alpha: 0.1);
      case BadgeVariant.error:
        return AppColors.error.withValues(alpha: 0.1);
      case BadgeVariant.info:
        return AppColors.primary.withValues(alpha: 0.1);
      case BadgeVariant.neutral:
        return AppColors.textSecondary.withValues(alpha: 0.1);
    }
  }

  Color get _fgColor {
    switch (variant) {
      case BadgeVariant.success:
        return AppColors.success;
      case BadgeVariant.warning:
        return AppColors.warning;
      case BadgeVariant.error:
        return AppColors.error;
      case BadgeVariant.info:
        return AppColors.primary;
      case BadgeVariant.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _fgColor,
        ),
      ),
    );
  }
}