import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// FEAT-05 — Điểm truy cập DUY NHẤT cho Device Identity trong toàn bộ app.
/// Không được import `device_info_plus`/`flutter_secure_storage` ở bất kỳ file
/// nào khác — mọi nơi cần installId/deviceInfo phải gọi qua class này. Xem
/// docs/design/ANTI_FRAUD_DESIGN.md §2 và
/// docs/implementation/FEAT_05_IMPLEMENTATION_PLAN.md §2.4.
///
/// `installId` là Installation Identity (gắn với lần cài app), KHÔNG phải
/// Device Identity thật — trên Android sẽ đổi nếu gỡ cài + cài lại, trên iOS
/// có thể sống sót qua gỡ cài (Keychain) — đây là đánh đổi đã chấp nhận, xem
/// thiết kế §2.1.
class DeviceService {
  static const _installIdKey = 'feat05_install_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Đọc `installId` đã lưu, sinh mới (UUID v4) nếu đây là lần đầu chạy app.
  Future<String> getInstallId() async {
    final existing = await _storage.read(key: _installIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final newId = const Uuid().v4();
    await _storage.write(key: _installIdKey, value: newId);
    return newId;
  }

  /// Thông tin thiết bị phụ trợ — CHỈ dùng để Admin xem/audit, KHÔNG dùng để
  /// enforce (nhiều máy cùng model/OS có giá trị giống hệt nhau, không unique).
  Future<Map<String, String>> getDeviceInfo() async {
    final plugin = DeviceInfoPlugin();
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await plugin.androidInfo;
        return {
          'platform': 'android',
          'model': info.model,
          'manufacturer': info.manufacturer,
          'osVersion': info.version.release,
        };
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await plugin.iosInfo;
        return {
          'platform': 'ios',
          'model': info.utsname.machine,
          'manufacturer': 'Apple',
          'osVersion': info.systemVersion,
        };
      }
    } catch (_) {
      // Thông tin phụ trợ cho mục đích audit — lỗi ở đây không nên chặn
      // luồng chính (installId vẫn là nguồn quyết định).
    }
    return {
      'platform': 'unknown',
      'model': '',
      'manufacturer': '',
      'osVersion': '',
    };
  }
}
