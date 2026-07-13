import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/clock_service.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../home/presentation/home_provider.dart';
import '../../domain/demo_status.dart';

/// Dải cảnh báo "đang chạy Demo Time", gắn ở đầu HomeScreen và
/// AttendanceHistoryScreen để giảng viên luôn thấy ngay cả khi người demo
/// không đứng ở màn Demo Center. Chỉ render khi ClockService.isDemoActive.
///
/// Tự cập nhật qua ValueListenableBuilder trên ClockService.demoTimeListenable
/// (không qua ref.invalidate) — xem docs/design/DEMO_TIME_DESIGN_v2.md mục 3.2.
class DemoModeBanner extends ConsumerWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: ClockService.demoTimeListenable,
      builder: (context, demoTime, _) {
        if (!ClockService.isDemoActive) return const SizedBox.shrink();

        final user = ref.watch(homeProvider).user;
        if (user == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => context.push('/demo-center'),
          child: Container(
            width: double.infinity,
            color: AppColors.warning,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: FutureBuilder<DemoStatus>(
              future: DemoStatusResolver.resolve(user.shiftGroup),
              builder: (context, snapshot) {
                final status = snapshot.data;
                final text = status == null
                    ? '🧪 DEMO — ${DateHelper.toDisplayDateTime(ClockService.now())}'
                    : '🧪 DEMO — ${DateHelper.toDisplayDateTime(ClockService.now())}'
                        ' · Ngày làm việc: ${DateHelper.toDisplayDate(status.businessDate)}'
                        ' · ${status.shiftLabel}';

                return Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
