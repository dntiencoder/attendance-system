import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/clock_service.dart';
import '../../../core/utils/date_helper.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../home/presentation/home_provider.dart';
import '../../attendance/presentation/attendance_provider.dart';
import '../../attendance/presentation/attendance_history_provider.dart';
import '../../auth/domain/user_model.dart';
import '../domain/demo_status.dart';

/// Màn hình mô phỏng thời gian phục vụ demo (chỉ khả dụng ở kDebugMode —
/// route /demo-center chỉ được liên kết tới từ ProfileScreen khi kDebugMode).
///
/// Xem docs/design/DEMO_TIME_DESIGN_v2.md mục 5 để biết đầy đủ thiết kế.
class DemoCenterScreen extends ConsumerStatefulWidget {
  const DemoCenterScreen({super.key});

  @override
  ConsumerState<DemoCenterScreen> createState() => _DemoCenterScreenState();
}

class _DemoCenterScreenState extends ConsumerState<DemoCenterScreen> {
  late DateTime _pickerDateTime;

  static const _fastForwardSteps = <String, Duration>{
    '+5 phút': Duration(minutes: 5),
    '+30 phút': Duration(minutes: 30),
    '+1 giờ': Duration(hours: 1),
    '+6 giờ': Duration(hours: 6),
    '+12 giờ': Duration(hours: 12),
    '+1 ngày': Duration(days: 1),
  };

  static const _rewindSteps = <String, Duration>{
    '-5 phút': Duration(minutes: 5),
    '-30 phút': Duration(minutes: 30),
    '-1 giờ': Duration(hours: 1),
    '-6 giờ': Duration(hours: 6),
    '-12 giờ': Duration(hours: 12),
    '-1 ngày': Duration(days: 1),
  };

  @override
  void initState() {
    super.initState();
    _pickerDateTime = ClockService.now();
  }

  void _invalidateBusinessProviders() {
    ref.invalidate(homeProvider);
    ref.invalidate(attendanceProvider);
    ref.invalidate(attendanceHistoryProvider);
  }

  void _applyDemoTime(DateTime time) {
    ClockService.setDemoTime(time);
    _invalidateBusinessProviders();
    setState(() => _pickerDateTime = time);
  }

  void _resetToRealTime() {
    ClockService.useRealTime();
    _invalidateBusinessProviders();
    setState(() => _pickerDateTime = DateTime.now());
  }

  void _shift(Duration delta) {
    _applyDemoTime(ClockService.now().add(delta));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickerDateTime,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    _applyDemoTime(DateTime(
      picked.year,
      picked.month,
      picked.day,
      _pickerDateTime.hour,
      _pickerDateTime.minute,
    ));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickerDateTime),
    );
    if (picked == null) return;
    _applyDemoTime(DateTime(
      _pickerDateTime.year,
      _pickerDateTime.month,
      _pickerDateTime.day,
      picked.hour,
      picked.minute,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDemoActive = ClockService.isDemoActive;
    final user = ref.watch(homeProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Demo Center'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _StatusCard(isDemoActive: isDemoActive, user: user),
          const SizedBox(height: AppSpacing.md),
          _buildDemoTimeSection(isDemoActive),
          const SizedBox(height: AppSpacing.md),
          _buildFastForwardSection(),
        ],
      ),
    );
  }

  Widget _buildDemoTimeSection(bool isDemoActive) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Demo Time',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Use Real Time'),
                    selected: !isDemoActive,
                    onSelected: (_) => _resetToRealTime(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Use Demo Time'),
                    selected: isDemoActive,
                    onSelected: (_) => _applyDemoTime(_pickerDateTime),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(DateHelper.toDisplayDate(_pickerDateTime)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(DateHelper.toTimeString(_pickerDateTime)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFastForwardSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fast Forward / Rewind',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _fastForwardSteps.entries
                  .map((e) => OutlinedButton(
                        onPressed: () => _shift(e.value),
                        child: Text(e.key),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _rewindSteps.entries
                  .map((e) => OutlinedButton(
                        onPressed: () => _shift(-e.value),
                        child: Text(e.key),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _resetToRealTime,
                icon: const Icon(Icons.restore),
                label: const Text('Reset to Current Time'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textSecondary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool isDemoActive;
  final UserModel? user;

  const _StatusCard({required this.isDemoActive, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDemoActive ? AppColors.warning : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isDemoActive ? '🧪 DEMO MODE' : 'Đang dùng thời gian thực',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDemoActive ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _row('Current Time',
                DateHelper.toDisplayDateTime(ClockService.now()), isDemoActive),
            if (user != null)
              Builder(
                builder: (context) {
                  final currentUser = user!;
                  return FutureBuilder<DemoStatus>(
                    future: DemoStatusResolver.resolve(currentUser.shiftGroup),
                    builder: (context, snapshot) {
                      final status = snapshot.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row(
                            'Business Date',
                            status != null
                                ? DateHelper.toDisplayDate(status.businessDate)
                                : '...',
                            isDemoActive,
                          ),
                          _row(
                            'Current Shift',
                            status != null ? status.shiftLabel : '...',
                            isDemoActive,
                          ),
                          _row(
                            'Current User',
                            '${currentUser.name} (${currentUser.employeeCode}) · Nhóm ${currentUser.shiftGroup}',
                            isDemoActive,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, bool isDemoActive) {
    final color = isDemoActive ? AppColors.white : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }
}
