import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/theme/app_colors.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    final items = [
      _Item(Icons.analytics_outlined, Icons.analytics, 'Bảng Tổng Quan', '/dashboard'),
      _Item(Icons.badge_outlined, Icons.badge, 'Quản Lý Nhân Viên', '/employees'),
      _Item(Icons.assignment_turned_in_outlined, Icons.assignment_turned_in, 'Nhật Ký Chấm Công', '/attendance'),
      _Item(Icons.mail_outline_rounded, Icons.mail_rounded, 'Duyệt Nghỉ Phép', '/leave'),
      _Item(Icons.pin_drop_outlined, Icons.pin_drop, 'Cấu Hình Vị Trí GPS', '/settings'),
    ];

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: items.map((item) {
          final isActive = currentPath == item.path;
          return _SidebarTile(
            item: item,
            isActive: isActive,
            onTap: () => context.go(item.path),
          );
        }).toList(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          isActive ? item.activeIcon : item.icon,
          color: isActive ? const Color(0xFFB91C1C) : const Color(0xFF64748B),
          size: 24,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xFFB91C1C) : const Color(0xFF64748B),
          ),
        ),
        selected: isActive,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: isActive ? const Color(0xFFB91C1C).withValues(alpha: 0.08) : null,
      ),
    );
  }
}
