import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'attendance_provider.dart';
import '../../../core/utils/date_helper.dart';

class CheckInScreen extends ConsumerWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceProvider);

    ref.listen(attendanceProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    final hasCheckedIn = state.todayAttendance?.checkIn != null;
    final hasCheckedOut = state.todayAttendance?.hasCheckedOut ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chấm công'),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ===== TRẠNG THÁI =====
            _buildStatusCard(state, hasCheckedIn, hasCheckedOut),

            const SizedBox(height: 32),

            // ===== NÚT CHECK IN =====
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: hasCheckedIn || state.isLoading
                    ? null
                    : () => ref
                    .read(attendanceProvider.notifier)
                    .checkIn(),
                icon: const Icon(Icons.login),
                label: const Text(
                  'Check In',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== NÚT CHECK OUT =====
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: !hasCheckedIn || hasCheckedOut || state.isLoading
                    ? null
                    : () => ref
                    .read(attendanceProvider.notifier)
                    .checkOut(),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Check Out',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Nút refresh
            TextButton.icon(
              onPressed: () => ref
                  .read(attendanceProvider.notifier)
                  .loadTodayAttendance(),
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(state, bool hasCheckedIn, bool hasCheckedOut) {
    // Chưa check in
    if (!hasCheckedIn) {
      return _StatusCard(
        icon: Icons.location_off,
        iconColor: Colors.grey,
        title: 'Chưa chấm công hôm nay',
        subtitle: 'Nhấn Check In để bắt đầu',
      );
    }

    // Đã check in, chưa check out
    if (hasCheckedIn && !hasCheckedOut) {
      return _StatusCard(
        icon: Icons.work,
        iconColor: Colors.blue,
        title: 'Đang làm việc',
        subtitle:
        'Check In lúc ${DateHelper.toTimeString(state.todayAttendance!.checkIn!)}',
        badge: state.todayAttendance!.isLate ? 'Đi muộn' : 'Đúng giờ',
        badgeColor: state.todayAttendance!.isLate ? Colors.orange : Colors.green,
      );
    }

    // Đã check out
    return _StatusCard(
      icon: Icons.check_circle,
      iconColor: Colors.green,
      title: 'Đã hoàn thành hôm nay',
      subtitle:
      'Check In: ${DateHelper.toTimeString(state.todayAttendance!.checkIn!)}\n'
          'Check Out: ${DateHelper.toTimeString(state.todayAttendance!.checkOut!)}\n'
          'Số giờ: ${state.todayAttendance!.workHours.toStringAsFixed(1)} giờ',
      badge: state.todayAttendance!.isLate ? 'Đi muộn' : 'Đúng giờ',
      badgeColor: state.todayAttendance!.isLate ? Colors.orange : Colors.green,
    );
  }
}

// Widget card trạng thái
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;

  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 72, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.6,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(height: 12),
              Chip(
                label: Text(badge!),
                backgroundColor: badgeColor,
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}