import 'package:flutter/material.dart';
import '../shared/theme/app_colors.dart';
import 'sidebar.dart';
import 'top_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          const SizedBox(width: 240, child: Sidebar()),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}