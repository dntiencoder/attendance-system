import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonVariant { primary, secondary, outline, danger }

/// Button dùng chung toàn app, hỗ trợ trạng thái loading và nhiều biến thể màu sắc
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  bool get _isFilled => variant == ButtonVariant.primary || variant == ButtonVariant.danger;

  Color get _accentColor {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.danger:
        return AppColors.error;
      case ButtonVariant.outline:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final loaderColor = _isFilled ? Colors.white : _accentColor;

    final child = isLoading
        ? SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: loaderColor),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );

    const padding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

    Widget button;
    switch (variant) {
      case ButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: padding,
            shape: shape,
          ),
          child: child,
        );
        break;
      case ButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            padding: padding,
            shape: shape.copyWith(side: const BorderSide(color: AppColors.border)),
          ),
          child: child,
        );
        break;
      case ButtonVariant.primary:
      case ButtonVariant.danger:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _accentColor.withValues(alpha: 0.5),
            padding: padding,
            shape: shape,
          ),
          child: child,
        );
    }

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}