import 'dart:developer' as developer;

/// Ghi log lỗi có cấu trúc ra console dev (TD-04, docs/project/01_BACKLOG.md).
/// Không thay đổi luồng xử lý lỗi hiện có (UI vẫn tự hiện thông báo như cũ),
/// chỉ thêm một điểm ghi lại để debug khi cần.
class AppLogger {
  AppLogger._();

  static void error(String context, Object error, [StackTrace? stackTrace]) {
    developer.log(
      error.toString(),
      name: context,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
