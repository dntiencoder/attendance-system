import 'package:flutter/foundation.dart';

/// Điểm neo duy nhất cho "thời gian hiện tại" của toàn bộ logic nghiệp vụ
/// chấm công (Business Date, Shift, Late, Early Leave...).
///
/// DEMO OFF hoặc Release/Production -> luôn trả về DateTime.now() thật.
/// DEMO ON (chỉ khả dụng ở kDebugMode, bật qua Demo Center) -> trả về
/// thời gian giả lập đã set.
///
/// Xem docs/design/DEMO_TIME_DESIGN_v2.md mục 3 để biết lý do chọn static
/// class thay vì singleton injectable hoặc Riverpod provider thuần.
class ClockService {
  ClockService._();

  static DateTime? _demoTime;

  /// Dùng cho widget cần tự rebuild khi Demo Time đổi (banner...), qua
  /// ValueListenableBuilder(valueListenable: ClockService.demoTimeListenable, ...).
  /// Không thay thế cơ chế ref.invalidate() của các provider Riverpod khác —
  /// xem mục 3.2/5.4 trong tài liệu thiết kế.
  static final ValueNotifier<DateTime?> demoTimeListenable =
      ValueNotifier<DateTime?>(null);

  static bool get isDemoActive => kDebugMode && _demoTime != null;

  static DateTime now() {
    if (kDebugMode && _demoTime != null) return _demoTime!;
    return DateTime.now();
  }

  static void setDemoTime(DateTime time) {
    if (!kDebugMode) return;
    _demoTime = time;
    demoTimeListenable.value = time;
  }

  static void useRealTime() {
    _demoTime = null;
    demoTimeListenable.value = null;
  }
}
