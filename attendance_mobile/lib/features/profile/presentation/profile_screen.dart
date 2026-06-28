import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
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
