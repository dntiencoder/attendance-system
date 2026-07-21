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
///
/// KHÔNG được thêm lại cơ chế "tự phục hồi" (thử ghi thẳng
/// users.trustedDeviceId trước khi kiểm mã) — bản đầu tiên từng có cơ chế
/// này và tạo ra lỗ hổng nghiêm trọng: một khi `device_activations/{uid}`
/// từng đạt trạng thái 'redeemed' bởi ĐÚNG thiết bị này, Rules cho phép ghi
/// lại `trustedDeviceId` với giá trị KHÔNG ĐỔI bất kỳ lúc nào sau đó — nghĩa
/// là gọi lại `redeemCode()` với BẤT KỲ chuỗi nào (kể cả rác) đều "thành
/// công" ngay, bỏ qua hoàn toàn bước kiểm mã, vì bước phục hồi chạy TRƯỚC và
/// không hề nhìn vào `enteredCode`. Phát hiện qua test tay thật (Admin cấp
/// lại mã cho nhân viên đã từng redeem — `users.trustedDeviceId` cũ vẫn còn,
/// khiến "phục hồi" luôn thắng). Đánh đổi chấp nhận: nếu Ghi 2 lỡ thất bại
/// giữa chừng (mất mạng ngay sau khi Write B thành công), nhân viên cần
/// Admin cấp mã MỚI thay vì tự bấm lại được — hẹp nhưng AN TOÀN, thay vì
/// tiện nhưng có lỗ hổng.
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
      // Write A: LUÔN ghi — tăng attemptCount (server-side, atomic, không
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
            'Không thể dùng mã này (đã hết hạn, hết lượt thử, đã được dùng '
            'trước đó, hoặc chưa từng được cấp).\n'
            'Vui lòng liên hệ quản trị viên để cấp mã mới.',
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

      // Ghi 2 — chỉ chạy khi Write B (ngay ở trên) VỪA thành công trong đúng
      // lần gọi redeemCode() này (không suy đoán từ trạng thái cũ để lại) —
      // đảm bảo mã luôn được kiểm tra thật mỗi lần gọi hàm, không có đường
      // tắt nào bỏ qua bước này.
      try {
        await userRef.update({
          'trustedDeviceId': installId,
          'deviceStatus': 'trusted',
        });
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          // Hiếm gặp (Write B vừa thành công) — có thể do mất mạng đúng lúc
          // giữa 2 lượt ghi. KHÔNG tự phục hồi (xem lý do ở đầu file) — cần
          // Admin cấp mã mới, không cho phép "bấm lại" tự động.
          throw Exception(
            'Kích hoạt gần hoàn tất nhưng chưa xong (có thể do mất mạng).\n'
            'Vui lòng liên hệ quản trị viên để được cấp mã kích hoạt mới.',
          );
        }
        rethrow;
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
