import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../attendance/presentation/attendance_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/loading_widget.dart';

import 'home_provider.dart';

import 'widgets/home_header.dart';
import 'widgets/checkin_card.dart';
import 'widgets/monthly_stats.dart';
import 'widgets/recent_attendance.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final homeState =
    ref.watch(homeProvider);

    final attendanceState =
    ref.watch(attendanceProvider);

    ref.listen<AttendanceState>(
      attendanceProvider,
          (previous, next) {
        if (next.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content:
              Text(next.error!),
              backgroundColor:
              AppColors.error,
            ),
          );
        }

        if (next.successMessage !=
            null) {
          final isCheckIn =
              previous
                  ?.todayAttendance ==
                  null &&
                  next.todayAttendance !=
                      null;

          final wasCheckOut =
              previous?.todayAttendance?.checkOut == null &&
                  next.todayAttendance?.checkOut != null;

          if (isCheckIn) {
            ref.read(homeProvider.notifier).loadMonthlyStatsOnly();
            ref.read(homeProvider.notifier).loadRecentAttendanceOnly();
          } else if (wasCheckOut) {
            ref.read(homeProvider.notifier).loadRecentAttendanceOnly();
          }

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                next.successMessage!,
              ),
              backgroundColor:
              AppColors.success,
            ),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor:
      AppColors.background,

      body: homeState.isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
        color:
        AppColors.primary,
        onRefresh: () => ref
            .read(
          homeProvider
              .notifier,
        )
            .refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HomeHeader(
                user:
                homeState.user,
                departmentName:
                homeState
                    .user
                    ?.departmentId ??
                    '',
              ),
            ),

            SliverPadding(
              padding:
              const EdgeInsets
                  .all(
                AppSpacing.sm,
              ),
              sliver: SliverList(
                delegate:
                SliverChildListDelegate(
                  [
                    CheckinCard(
                      // QUAN TRỌNG
                      todayAttendance:
                      attendanceState
                          .todayAttendance,

                      selectedShift:
                      homeState
                          .selectedShift,

                      isLoading:
                      attendanceState
                          .isLoading,

                      onCheckIn:
                          () async {
                        await ref
                            .read(
                          attendanceProvider
                              .notifier,
                        )
                            .checkIn();
                      },

                      onCheckOut:
                          () async {
                        await ref
                            .read(
                          attendanceProvider
                              .notifier,
                        )
                            .checkOut();
                      },

                      onShiftChanged:
                          (shift) {
                        ref
                            .read(
                          homeProvider
                              .notifier,
                        )
                            .selectShift(
                          shift,
                        );
                      },
                    ),

                    const SizedBox(
                      height:
                      AppSpacing
                          .md,
                    ),

                    MonthlyStats(
                      total:
                      homeState
                          .monthlyTotal,
                      early:
                      homeState
                          .monthlyEarly,
                      late:
                      homeState
                          .monthlyLate,
                      leave:
                      homeState
                          .monthlyLeave,
                      month:
                      DateTime
                          .now(),
                    ),

                    const SizedBox(
                      height:
                      AppSpacing
                          .md,
                    ),

                    RecentAttendance(
                      records:
                      homeState
                          .recentAttendance,
                    ),

                    const SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
      BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor:
        AppColors.primary,
        unselectedItemColor:
        AppColors.textSecondary,
        type:
        BottomNavigationBarType
            .fixed,
        backgroundColor:
        AppColors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            activeIcon:
            Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons
                  .access_time_outlined,
            ),
            activeIcon: Icon(
              Icons.access_time,
            ),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons
                  .description_outlined,
            ),
            activeIcon: Icon(
              Icons.description,
            ),
            label: 'Nghỉ phép',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            activeIcon:
            Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
        onTap: (index) {},
      ),
    );

  }
}