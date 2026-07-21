import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// FEAT-05 — luồng cấp mã kích hoạt thiết bị phía Admin. Xem
/// docs/design/ANTI_FRAUD_DESIGN.md §4 (entropy/TTL/rate limiting).
class DeviceActivationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const _ttl = Duration(minutes: 15);

  /// Sinh mã 6 số ngẫu nhiên, ghi đè `device_activations/{uid}` — mã cũ (nếu
  /// còn) tự động vô hiệu vì giá trị so khớp đã đổi. `newDeviceId` để trống:
  /// Admin không biết trước `installId` của máy mới, giá trị này do chính
  /// máy đang redeem điền vào (xem DeviceActivationRepository ở mobile).
  Future<String> issueCode(String uid) async {
    final code = _generateCode();
    final now = DateTime.now();

    await _db.collection('device_activations').doc(uid).set({
      'code': code,
      'newDeviceId': '',
      'attemptCount': 0,
      'lastAttemptCode': '',
      'expiresAt': Timestamp.fromDate(now.add(_ttl)),
      'status': 'pending',
    });

    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _db.collection('device_audit_log').add({
      'uid': uid,
      'eventType': 'code_issued',
      'actorUid': adminUid,
      'actorRole': 'admin',
      'timestamp': Timestamp.fromDate(now),
    });

    return code;
  }

  String _generateCode() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  /// Thu hồi ngay quyền thiết bị hiện tại của nhân viên — dùng khi mất máy,
  /// thiết bị hỏng, hoặc offboarding (xem
  /// docs/design/ANTI_FRAUD_DESIGN.md §4.1/§5). Bắt buộc [reason] không
  /// rỗng — kiểm tra ở tầng UI (dialog), repository không tự validate lại vì
  /// đây không phải input trực tiếp từ người dùng cuối chưa qua form.
  Future<void> resetDevice(String uid, String reason) async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final now = DateTime.now();

    await _db.collection('users').doc(uid).update({
      'trustedDeviceId': null,
      'deviceStatus': 'none',
    });

    // Vô hiệu hoá mã đang chờ nhập (nếu có) bằng cách đưa expiresAt về quá
    // khứ — Admin có quyền đọc collection này nên an toàn để get() trước khi
    // update() (khác nhân viên, không bao giờ được đọc — xem
    // device_activation_repository.dart ở mobile).
    final activationRef = _db.collection('device_activations').doc(uid);
    final activationDoc = await activationRef.get();
    if (activationDoc.exists) {
      await activationRef.update({'expiresAt': Timestamp.fromDate(now)});
    }

    await _db.collection('device_audit_log').add({
      'uid': uid,
      'eventType': 'admin_reset',
      'actorUid': adminUid,
      'actorRole': 'admin',
      'reason': reason,
      'timestamp': Timestamp.fromDate(now),
    });
  }
}
