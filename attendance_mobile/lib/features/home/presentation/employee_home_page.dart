import 'package:flutter/material.dart';

import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';

class EmployeeHomePage extends StatelessWidget {
  final UserModel user;

  const EmployeeHomePage({
    super.key,
    required this.user,
  });

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthRepository().logout();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng xuất thất bại: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang nhân viên'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào ${user.name}',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height: 16),

            Text('Mã nhân viên: ${user.employeeCode}'),

            const SizedBox(height: 8),

            Text('Email: ${user.email}'),

            const SizedBox(height: 8),

            Text('Vai trò: ${user.role}'),

            const SizedBox(height: 8),

            Text(
              user.isActive
                  ? 'Trạng thái: Đang hoạt động'
                  : 'Trạng thái: Đã khóa',
            ),
          ],
        ),
      ),
    );
  }
}