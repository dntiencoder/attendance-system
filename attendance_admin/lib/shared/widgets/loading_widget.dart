import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Spinner đơn giản, có thể kèm message, dùng khi loading dữ liệu trong 1 vùng
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingWidget({super.key, this.message, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

/// Overlay loading toàn vùng, dùng khi đang xử lý request (vd: xoá, lưu dữ liệu)
/// trong khi vẫn hiển thị nội dung phía dưới mờ đi
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.05),
              child: const LoadingWidget(),
            ),
          ),
      ],
    );
  }
}