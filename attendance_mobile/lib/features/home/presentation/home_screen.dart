import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../attendance/presentation/attendance_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';

import 'home_provider.dart';

import 'widgets/home_header.dart';
import 'widgets/checkin_card.dart';
import 'widgets/monthly_stats.dart';
import 'widgets/recent_attendance.dart';
import 'widgets/home_skeleton.dart';

import '../../../shared/utils/snackbar_utils.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final attendanceState = ref.watch(attendanceProvider);

    ref.listen<AttendanceState>(
      attendanceProvider,
      (previous, next) {
        if (next.error != null) {
          SnackBarUtils.showError(context, next.error!);
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

          SnackBarUtils.showSuccess(context, next.successMessage!);
        }
      },
    );

    if (homeState.isLoading) {
      return const HomeSkeleton();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(homeProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HomeHeader(
                user: homeState.user,
                departmentName: homeState.departmentName ?? '',
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
                      onTimeDays: homeState.monthlyOnTime,
                      earlyDays: homeState.monthlyEarly,
                      lateDays: homeState.monthlyLate,
                      absentDays: homeState.monthlyAbsent,
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
      ),
    );
  }
}
