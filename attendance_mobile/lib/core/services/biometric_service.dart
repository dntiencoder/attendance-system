import 'package:local_auth/local_auth.dart';

/// FEAT-05 — Điểm truy cập DUY NHẤT cho `local_auth` trong toàn bộ app (cùng
/// nguyên tắc "1 package = 1 lớp truy cập" như DeviceService, xem
/// docs/implementation/FEAT_05_IMPLEMENTATION_PLAN.md §2.4).
///
/// Chỉ dùng ở đúng 2 điểm chạm đã chốt trong thiết kế: Check In, Check Out —
/// xem docs/design/ANTI_FRAUD_DESIGN.md §9.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Yêu cầu xác thực sinh trắc học, có fallback PIN/pattern/mật khẩu màn
  /// hình khoá nếu máy không có cảm biến vân tay/khuôn mặt (`biometricOnly:
  /// false` — đúng thiết kế, đảm bảo hoạt động trên mọi máy).
  ///
  /// Trả `true` nếu xác thực thành công. Trả `false` (không throw) cho mọi
  /// trường hợp thất bại/huỷ/không khả dụng — nơi gọi tự quyết định thông
  /// điệp hiển thị phù hợp ngữ cảnh Check In/Check Out.
  Future<bool> authenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canCheck) return false;

      return await _auth.authenticate(
        localizedReason: 'Xác thực để xác nhận chấm công',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
