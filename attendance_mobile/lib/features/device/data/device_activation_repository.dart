import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/device_service.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/device_activation_model.dart';

/// FEAT-05 — luồng nhập/kiểm mã kích hoạt phía nhân viên. Xem
/// docs/implementation/FEAT_05_IMPLEMENTATION_PLAN.md §2.1 để biết vì sao
/// tách thành 2 lượt ghi tuần tự thay vì 1 giao dịch atomic xuyên 2 document.
class DeviceActivationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DeviceService _deviceService = DeviceService();

  /// Ghi 1: đối chiếu mã NGAY TRONG document `device_activations/{uid}`
  /// (không cần get() chéo document). Nếu đúng, lưu luôn `installId` của máy
  /// đang redeem làm `newDeviceId` (Admin lúc cấp mã KHÔNG biết trước giá trị
  /// này) và chuyển `status: 'pending' -> 'redeemed'`. Sai mã vẫn phải tăng
  /// `attemptCount` trong cùng giao dịch (rate limiting, §4.3 thiết kế).
  ///
  /// Ghi 2: cập nhật `users/{uid}.trustedDeviceId` — chỉ chạy khi Ghi 1 không
  /// ném lỗi.
  Future<void> redeemCode(String enteredCode) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    final installId = await _deviceService.getInstallId();
    final docRef = _db.collection('device_activations').doc(user.uid);

    try {
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception(
            'Chưa có mã kích hoạt nào được cấp cho tài khoản này.\n'
            'Vui lòng liên hệ quản trị viên.',
          );
        }

        final activation = DeviceActivationModel.fromFirestore(snapshot);

        if (activation.status == 'redeemed') {
          throw Exception(
            'Mã này đã được sử dụng.\nVui lòng liên hệ quản trị viên để cấp mã mới.',
          );
        }

        if (activation.isLocked) {
          throw Exception(
            'Mã đã bị khoá do nhập sai quá nhiều lần.\n'
            'Vui lòng liên hệ quản trị viên để cấp mã mới.',
          );
        }

        if (activation.isExpired) {
          transaction.update(docRef, {'status': 'locked'});
          throw Exception(
            'Mã đã hết hạn.\nVui lòng liên hệ quản trị viên để cấp mã mới.',
          );
        }

        if (activation.code != enteredCode.trim()) {
          final nextAttempt = activation.attemptCount + 1;
          final locked = nextAttempt >= DeviceActivationModel.maxAttempts;
          transaction.update(docRef, {
            'attemptCount': nextAttempt,
            if (locked) 'status': 'locked',
          });
          throw Exception(
            locked
                ? 'Mã kích hoạt không đúng. Đã hết số lần thử — vui lòng liên hệ quản trị viên để cấp mã mới.'
                : 'Mã kích hoạt không đúng. Còn ${DeviceActivationModel.maxAttempts - nextAttempt} lần thử.',
          );
        }

        // Đúng mã — Ghi 1: đánh dấu redeemed, lưu installId của máy đang
        // redeem làm newDeviceId (Ghi 2 sẽ dùng lại đúng giá trị này).
        transaction.update(docRef, {
          'status': 'redeemed',
          'newDeviceId': installId,
          'attemptCount': activation.attemptCount + 1,
        });
      });

      // Ghi 2 — chỉ chạy khi Ghi 1 (transaction ở trên) không ném lỗi.
      await _db.collection('users').doc(user.uid).update({
        'trustedDeviceId': installId,
        'deviceStatus': 'trusted',
      });

      await _db.collection('device_audit_log').add({
        'uid': user.uid,
        'eventType': 'activated',
        'newDeviceId': installId,
        'actorUid': user.uid,
        'actorRole': 'employee',
        'deviceInfo': await _deviceService.getDeviceInfo(),
        'timestamp': Timestamp.now(),
      });
    } on FirebaseException catch (e, st) {
      AppLogger.error('DeviceActivationRepository.redeemCode', e, st);
      if (e.code == 'unavailable') {
        throw Exception(
          'Không có kết nối Internet. Vui lòng kết nối mạng trước khi kích hoạt.',
        );
      }
      rethrow;
    }
  }

  /// So khớp `installId` hiện tại với `trustedDeviceId` đã lưu — dùng ngay sau
  /// login để quyết định có cần điều hướng sang màn nhập mã hay không.
  Future<bool> isCurrentDeviceTrusted({
    required String? trustedDeviceId,
  }) async {
    if (trustedDeviceId == null || trustedDeviceId.isEmpty) return false;
    final installId = await _deviceService.getInstallId();
    return installId == trustedDeviceId;
  }
}
