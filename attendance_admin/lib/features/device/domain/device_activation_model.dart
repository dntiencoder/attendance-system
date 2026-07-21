import 'package:cloud_firestore/cloud_firestore.dart';

/// FEAT-05 — `device_activations/{uid}`, 1 document hiện hành/nhân viên (doc ID
/// = uid). Xem docs/design/ANTI_FRAUD_DESIGN.md §4 (entropy/TTL/rate limiting).
class DeviceActivationModel {
  /// = doc.id (uid nhân viên).
  final String uid;

  /// Chỉ có ý nghĩa khi Admin đọc (Admin có quyền `get` trên collection này).
  /// Nhân viên KHÔNG BAO GIỜ được cấp quyền đọc document này — việc đối
  /// chiếu mã diễn ra hoàn toàn phía Rules qua `lastAttemptCode`, xem
  /// `DeviceActivationRepository.redeemCode()` (mobile) và
  /// docs/implementation/FEAT_05_IMPLEMENTATION_PLAN.md §2.1.
  final String code;
  final String newDeviceId;
  final int attemptCount;

  /// Mã nhân viên vừa nhập ở lượt thử gần nhất — Rules so khớp field này với
  /// `code` để quyết định cho phép chuyển `status` sang 'redeemed' hay không.
  final String lastAttemptCode;

  final DateTime expiresAt;

  /// pending | redeemed
  final String status;

  const DeviceActivationModel({
    required this.uid,
    required this.code,
    required this.newDeviceId,
    required this.attemptCount,
    this.lastAttemptCode = '',
    required this.expiresAt,
    required this.status,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  static const int maxAttempts = 5;

  bool get isLocked => attemptCount >= maxAttempts;

  factory DeviceActivationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeviceActivationModel(
      uid: doc.id,
      code: data['code'] ?? '',
      newDeviceId: data['newDeviceId'] ?? '',
      attemptCount: data['attemptCount'] ?? 0,
      lastAttemptCode: data['lastAttemptCode'] ?? '',
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
      'lastAttemptCode': lastAttemptCode,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'status': status,
    };
  }
}
