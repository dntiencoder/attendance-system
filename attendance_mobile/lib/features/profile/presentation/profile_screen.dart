import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            ProfileHeaderCard(user: user),
            const SizedBox(height: AppSpacing.md),
            ProfileInfoList(
              user: user,
              departmentName: homeState.departmentName ?? '',
            ),
            const SizedBox(height: AppSpacing.lg),

            const LogoutButton(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
