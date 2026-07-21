import 'package:cloud_firestore/cloud_firestore.dart';

/// FEAT-05 — `device_audit_log/{id}`, append-only. Đóng vai trò Activation
/// History (không tạo collection riêng — xem
/// docs/design/ANTI_FRAUD_DESIGN.md §6/§7).
class DeviceAuditLogModel {
  final String id;
  final String uid;

  /// code_issued | activated | admin_reset | code_expired | code_locked
  final String eventType;

  final String? oldDeviceId;
  final String? newDeviceId;
  final String actorUid;

  /// admin | employee
  final String actorRole;

  final String? reason;
  final Map<String, dynamic>? deviceInfo;
  final DateTime timestamp;

  const DeviceAuditLogModel({
    required this.id,
    required this.uid,
    required this.eventType,
    this.oldDeviceId,
    this.newDeviceId,
    required this.actorUid,
    required this.actorRole,
    this.reason,
    this.deviceInfo,
    required this.timestamp,
  });

  factory DeviceAuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeviceAuditLogModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      eventType: data['eventType'] ?? '',
      oldDeviceId: data['oldDeviceId'],
      newDeviceId: data['newDeviceId'],
      actorUid: data['actorUid'] ?? '',
      actorRole: data['actorRole'] ?? '',
      reason: data['reason'],
      deviceInfo: data['deviceInfo'] is Map
          ? Map<String, dynamic>.from(data['deviceInfo'])
          : null,
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'eventType': eventType,
      'oldDeviceId': oldDeviceId,
      'newDeviceId': newDeviceId,
      'actorUid': actorUid,
      'actorRole': actorRole,
      'reason': reason,
      'deviceInfo': deviceInfo,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
