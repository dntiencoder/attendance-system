import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/theme/app_colors.dart';
import '../shared/theme/app_spacing.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    final items = [
      _Item(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', '/dashboard'),
      _Item(Icons.people_outline, Icons.people, 'Nhân viên', '/employees'),
      _Item(Icons.access_time_outlined, Icons.access_time, 'Chấm công', '/attendance'),
      _Item(Icons.description_outlined, Icons.description, 'Nghỉ phép', '/leave'),
      _Item(Icons.business_outlined, Icons.business, 'Phòng ban', '/departments'),
      _Item(Icons.settings_outlined, Icons.settings, 'Cài đặt', '/settings'),
    ];

    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          // Logo header
          Container(
            height: 64,
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Image.asset(
                  'assets/logo_umc.jpg',
                  height: 32,
                  errorBuilder: (_, __, ___) => const Text(
                    'UMC Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              children: items.map((item) {
                final isActive = currentPath == item.path;
                return _SidebarTile(
                  item: item,
                  isActive: isActive,
                  onTap: () => context.go(item.path),
                );
              }).toList(),
            ),
          ),

          // Đăng xuất
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error, size: 20),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: AppColors.error, fontSize: 14),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  _Item(this.icon, this.activeIcon, this.label, this.path);
}

class _SidebarTile extends StatelessWidget {
  final _Item item;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Icon(
          isActive ? item.activeIcon : item.icon,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        selected: isActive,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
      ),
    );
  }
}