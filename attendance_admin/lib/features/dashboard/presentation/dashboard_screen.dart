import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import 'dashboard_provider.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(dashboardStatsProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: statsAsync.when(
          loading: () => const SizedBox(
            height: 400,
            child: LoadingWidget(message: 'Đang tải dữ liệu...'),
          ),
          error: (err, _) => SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Không thể tải dữ liệu: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => ref.invalidate(dashboardStatsProvider),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
          data: (stats) => _DashboardContent(stats: stats),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardStats stats;
  const _DashboardContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1100
                ? 4
                : constraints.maxWidth > 700
                ? 2
                : 1;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.7,
              children: [
                StatCard(
                  label: 'Tổng nhân viên',
                  value: '${stats.totalEmployees}',
                  icon: Icons.people_outline,
                  color: AppColors.primary,
                ),
                StatCard(
                  label: 'Đã chấm công hôm nay',
                  value: '${stats.todayCheckedIn}/${stats.activeEmployees}',
                  icon: Icons.access_time_outlined,
                  color: AppColors.success,
                  trend: '${stats.attendanceRate.toStringAsFixed(0)}%',
                  trendUp: stats.attendanceRate >= 80,
                ),
                StatCard(
                  label: 'Đơn nghỉ phép chờ duyệt',
                  value: '${stats.pendingLeaveRequests}',
                  icon: Icons.description_outlined,
                  color: AppColors.warning,
                ),
                StatCard(
                  label: 'Phòng ban',
                  value: '${stats.totalDepartments}',
                  icon: Icons.business_outlined,
                  color: AppColors.textSecondary,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chấm công 7 ngày gần nhất',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 220,
                child: _WeeklyBarChart(data: stats.weeklyAttendance),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<DailyAttendanceCount> data;
  const _WeeklyBarChart({required this.data});

  static const _weekdayLabels = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final counts = data.map((e) => e.count).toList();
    final maxCount = counts.isEmpty ? 0 : counts.reduce((a, b) => a > b ? a : b);
    final maxY = (maxCount * 1.3).clamp(5, double.infinity).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _weekdayLabels[data[index].date.weekday],
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(data.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[index].count.toDouble(),
                color: AppColors.primary,
                width: 22,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }
}