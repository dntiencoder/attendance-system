import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../attendance/presentation/attendance_provider.dart';
import '../../attendance/presentation/attendance_history_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/loading_widget.dart';

import 'home_provider.dart';

import 'widgets/home_header.dart';
import 'widgets/checkin_card.dart';
import 'widgets/monthly_stats.dart';
import 'widgets/recent_attendance.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const AttendanceHistoryScreen(),
    const Center(child: Text('Nghỉ phép')),
    const ProfileScreen(), // ← thay thế Center Hồ sơ
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen<AttendanceState>(
      attendanceProvider,
      (previous, next) {
        if (next.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }

        if (next.successMessage != null) {
          final isCheckIn = previous?.todayAttendance == null && next.todayAttendance != null;
          final wasCheckOut = previous?.todayAttendance?.checkOut == null && next.todayAttendance?.checkOut != null;

          if (isCheckIn) {
            ref.read(homeProvider.notifier).loadMonthlyStatsOnly();
            ref.read(homeProvider.notifier).loadRecentAttendanceOnly();
          } else if (wasCheckOut) {
            ref.read(homeProvider.notifier).loadRecentAttendanceOnly();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          elevation: 0,
          items: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'Trang chủ', 0),
            _buildNavItem(Icons.access_time_outlined, Icons.access_time, 'Lịch sử', 1),
            _buildNavItem(Icons.description_outlined, Icons.description, 'Nghỉ phép', 2),
            _buildNavItem(Icons.person_outline, Icons.person, 'Hồ sơ', 3),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isSelected ? 4 : 0),
        child: Icon(isSelected ? activeIcon : icon),
      ),
      label: label,
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final attendanceState = ref.watch(attendanceProvider);

    if (homeState.isLoading) {
      return const LoadingWidget();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(homeProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HomeHeader(
              user: homeState.user,
              departmentName: homeState.departmentName ?? '', // ← dùng tên thật
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  CheckinCard(
                    todayAttendance: attendanceState.todayAttendance,
                    selectedShift: homeState.selectedShift,
                    isLoading: attendanceState.isLoading,
                    onCheckIn: () async {
                      await ref.read(attendanceProvider.notifier).checkIn();
                    },
                    onCheckOut: () async {
                      await ref.read(attendanceProvider.notifier).checkOut();
                    },
                    onShiftChanged: (shift) {
                      ref.read(homeProvider.notifier).selectShift(shift);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  MonthlyStats(
                    total: homeState.monthlyTotal,
                    early: homeState.monthlyEarly,
                    late: homeState.monthlyLate,
                    leave: homeState.monthlyLeave,
                    month: DateTime.now(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RecentAttendance(
                    records: homeState.recentAttendance,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}