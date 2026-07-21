import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/device_audit_log_model.dart';

/// FEAT-05 — đọc lịch sử thiết bị cho Admin, đóng vai trò Activation
/// History (không tạo collection riêng, xem
/// docs/design/ANTI_FRAUD_DESIGN.md §6).
class DeviceAuditLogRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Sort client-side theo timestamp — tránh cần composite index mới, đúng
  /// pattern đã dùng cho leave_requests/notifications/attendance_history
  /// (tránh lặp lại BUG-015).
  Stream<List<DeviceAuditLogModel>> getLogsForUser(String uid) {
    return _db
        .collection('device_audit_log')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final logs = <DeviceAuditLogModel>[];
      for (final doc in snapshot.docs) {
        try {
          logs.add(DeviceAuditLogModel.fromFirestore(doc));
        } catch (_) {
          // Bỏ qua document lỗi để không làm crash toàn bộ danh sách.
        }
      }
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    });
  }
}
