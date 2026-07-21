import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/presentation/auth_provider.dart';
import 'device_activation_provider.dart';

/// FEAT-05 — hiển thị khi thiết bị hiện tại chưa khớp `trustedDeviceId` của
/// tài khoản (lần đầu đăng nhập hoặc đổi máy). Nhân viên nhập mã kích hoạt do
/// Admin cấp qua kênh ngoài app (điện thoại/gặp trực tiếp) — xem
/// docs/design/ANTI_FRAUD_DESIGN.md §3/§4.
class DeviceActivationScreen extends ConsumerStatefulWidget {
  const DeviceActivationScreen({super.key});

  @override
  ConsumerState<DeviceActivationScreen> createState() =>
      _DeviceActivationScreenState();
}

class _DeviceActivationScreenState
    extends ConsumerState<DeviceActivationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(deviceActivationProvider.notifier)
        .redeemCode(_codeController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceActivationProvider);

    ref.listen(deviceActivationProvider, (prev, next) {
      if (next.success) {
        // Cập nhật cache của router NGAY để lần redirect tiếp theo không gọi
        // lại Firestore và không bị đẩy ngược về màn này.
        AppRouter.markCurrentDeviceTrusted();
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Kích hoạt thiết bị'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => ref.read(authProvider.notifier).signOut(),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.phonelink_lock_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Thiết bị này chưa được kích hoạt cho tài khoản của bạn.\n'
                'Vui lòng liên hệ quản trị viên để lấy mã kích hoạt (6 số).',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: const InputDecoration(
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().length != 6) {
                    return 'Vui lòng nhập đủ 6 số';
                  }
                  return null;
                },
              ),
              if (state.error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  state.error!,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              CustomButton(
                text: 'Xác nhận',
                isLoading: state.isLoading,
                onPressed: state.isLoading ? null : _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
