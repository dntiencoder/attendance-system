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
}
