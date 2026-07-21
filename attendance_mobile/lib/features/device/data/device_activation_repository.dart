import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/device_service.dart';
import '../../../core/utils/app_logger.dart';

/// FEAT-05 — luồng nhập/kiểm mã kích hoạt phía nhân viên.
///
/// NGUYÊN TẮC BẢO MẬT BẮT BUỘC: repository này KHÔNG BAO GIỜ được gọi
/// `get()`/`snapshots()` trên `device_activations/{uid}` — Firestore không hỗ
/// trợ bảo mật theo từng field trong 1 lượt đọc, nên chỉ cần cấp `allow read`
/// để đọc 1 field vô hại (vd `attemptCount`) là vô tình lộ luôn field `code`.
/// Toàn bộ việc so khớp mã diễn ra HOÀN TOÀN phía Rules, client chỉ "ghi mù"
/// và suy luận kết quả từ việc ghi có bị từ chối hay không. Xem
/// docs/design/ANTI_FRAUD_DESIGN.md §4.6/§8.2 và
/// docs/implementation/FEAT_05_IMPLEMENTATION_PLAN.md §2.1.
class DeviceActivationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DeviceService _deviceService = DeviceService();

  Future<void> redeemCode(String enteredCode) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    final installId = await _deviceService.getInstallId();
    final activationRef = _db.collection('device_activations').doc(user.uid);
    final userRef = _db.collection('users').doc(user.uid);

    try {
      // Bước 0 (phục hồi): thử Ghi 2 TRƯỚC, mù hoàn toàn — nếu ở lần thử
      // trước đó Write B (bên dưới) đã thành công nhưng Ghi 2 bị gián đoạn
      // (vd mất mạng), thao tác này tự thành công ngay mà không cần nhập lại
      // mã, không cần lặp lại Write A/B (đã bị khoá lại vì status không còn
      // 'pending'). Nếu đây là lần thử đầu tiên (bình thường), thao tác này
      // bị từ chối (permission-denied) và ta rơi xuống luồng đầy đủ bên dưới.
      final recovered = await _tryMarkTrusted(userRef, installId);
      if (recovered) return;

      // Write A: LUÔN ghi — tăng attemptCount() (server-side, atomic, không
      // cần đọc giá trị cũ) và ghi lại "mã vừa nhập" để Write B đối chiếu.
      // Rules từ chối thẳng nếu status != 'pending' hoặc đã hết hạn/hết lượt
      // thử — nghĩa là permission-denied ở BƯỚC NÀY = "không thể dùng mã này
      // nữa", không phải "mã sai".
      try {
        await activationRef.update({
          'attemptCount': FieldValue.increment(1),
          'lastAttemptCode': enteredCode.trim(),
        });
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          throw Exception(
            'Không thể dùng mã này (đã hết hạn, hết lượt thử, hoặc chưa từng '
            'được cấp).\nVui lòng liên hệ quản trị viên để cấp mã mới.',
          );
        }
        rethrow;
      }

      // Write B: chỉ thành công nếu Rules xác nhận lastAttemptCode (vừa ghi ở
      // Write A) khớp code thật đang lưu — client KHÔNG BAO GIỜ đọc code,
      // không biết trước kết quả, chỉ biết qua việc ghi có bị từ chối không.
      try {
        await activationRef.update({
          'status': 'redeemed',
          'newDeviceId': installId,
        });
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          throw Exception('Mã kích hoạt không đúng. Vui lòng thử lại.');
        }
        rethrow;
      }

      // Ghi 2 thật sự — Write B vừa thành công nên chắc chắn hợp lệ.
      final ghi2Ok = await _tryMarkTrusted(userRef, installId);
      if (!ghi2Ok) {
        // Không nên xảy ra (Write B vừa thành công) — vẫn xử lý an toàn.
        throw Exception(
          'Kích hoạt gần như thành công nhưng chưa hoàn tất.\n'
          'Vui lòng thử lại — hệ thống sẽ tự nhận ra và hoàn tất ngay.',
        );
      }

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

  /// Ghi mù `users/{uid}.trustedDeviceId` — Rules chỉ chấp nhận nếu
  /// `device_activations/{uid}` đang ở trạng thái 'redeemed' với đúng
  /// `newDeviceId`. Trả `false` (không throw) khi bị từ chối vì đó là kết
  /// quả BÌNH THƯỜNG khi chưa/không đủ điều kiện, không phải lỗi.
  Future<bool> _tryMarkTrusted(
    DocumentReference<Map<String, dynamic>> userRef,
    String installId,
  ) async {
    try {
      await userRef.update({
        'trustedDeviceId': installId,
        'deviceStatus': 'trusted',
      });
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return false;
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
