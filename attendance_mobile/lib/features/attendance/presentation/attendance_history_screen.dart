import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import 'attendance_history_provider.dart';
import 'widgets/attendance_filter_chips.dart';
import 'widgets/attendance_record_list.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          _AttendanceHeader(
            month: state.selectedMonth,
            onPrevMonth: () =>
                ref.read(attendanceHistoryProvider.notifier).prevMonth(),
            onNextMonth: () =>
                ref.read(attendanceHistoryProvider.notifier).nextMonth(),
          ),

          // Filter chips
          AttendanceFilterChips(
            selected: state.selectedFilter,
            onSelected: (filter) => ref
                .read(attendanceHistoryProvider.notifier)
                .setFilter(filter),
          ),

          // Danh sách
          Expanded(
            child: state.isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
                : state.filteredRecords.isEmpty
                ? Center(
              child: Text(
                'Không có dữ liệu',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
                : AttendanceRecordList(
              records: state.filteredRecords,
            ),
          ),
        ],
      ),
    );
  }
}

// Header — không có nút back
class _AttendanceHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const _AttendanceHeader({
    required this.month,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.of(context).padding.top + AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch sử chấm công',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Điều hướng tháng
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onPrevMonth,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                Text(
                  'Tháng ${month.month.toString().padLeft(2, '0')} / ${month.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: onNextMonth,
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
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