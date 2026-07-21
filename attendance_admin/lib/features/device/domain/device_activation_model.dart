import 'package:cloud_firestore/cloud_firestore.dart';

/// FEAT-05 — `device_activations/{uid}`, 1 document hiện hành/nhân viên (doc ID
/// = uid). Xem docs/design/ANTI_FRAUD_DESIGN.md §4 (entropy/TTL/rate limiting).
class DeviceActivationModel {
  /// = doc.id (uid nhân viên).
  final String uid;

  final String code;
  final String newDeviceId;
  final int attemptCount;
  final DateTime expiresAt;

  /// pending | redeemed | locked
  final String status;

  const DeviceActivationModel({
    required this.uid,
    required this.code,
    required this.newDeviceId,
    required this.attemptCount,
    required this.expiresAt,
    required this.status,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  static const int maxAttempts = 5;

  bool get isLocked => status == 'locked' || attemptCount >= maxAttempts;

  factory DeviceActivationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeviceActivationModel(
      uid: doc.id,
      code: data['code'] ?? '',
      newDeviceId: data['newDeviceId'] ?? '',
      attemptCount: data['attemptCount'] ?? 0,
      expiresAt: data['expiresAt'] is Timestamp
          ? (data['expiresAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'newDeviceId': newDeviceId,
      'attemptCount': attemptCount,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'status': status,
    };
  }
}
