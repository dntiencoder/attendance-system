import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../home/presentation/home_provider.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_info_list.dart';
import 'widgets/logout_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final user = homeState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundTertiary, // Use tertiary bg from prototype
      body: Column(
        children: [
          ProfileHeaderCard(
            user: user,
            departmentName: homeState.departmentName ?? '',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ProfileInfoList(
                    user: user,
                    departmentName: homeState.departmentName ?? '',
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 10),
                    _DemoCenterTile(onTap: () => context.push('/demo-center')),
                  ],
                  const SizedBox(height: 10),
                  const LogoutButton(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chỉ hiển thị khi kDebugMode — lối vào Demo Center (xem
/// docs/design/DEMO_TIME_DESIGN_v2.md).
class _DemoCenterTile extends StatelessWidget {
  final VoidCallback onTap;

  const _DemoCenterTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.science_outlined, size: 14, color: AppColors.warning),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Demo Center',
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
