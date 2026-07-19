import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../domain/attendance_model.dart';
import '../../../services/gps_service.dart';
import '../../../features/settings/domain/company_settings_model.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/business_date_helper.dart';
import '../../../core/services/clock_service.dart';
import '../../../core/utils/app_logger.dart';

class AttendanceRepository {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final GpsService _gpsService =
  GpsService();

  /// Khung ân hạn Check Out muộn cho ca đêm (đã chốt ở
  /// docs/design/ATTENDANCE_BUSINESS_FLOW.md).
  static const _checkOutGracePeriod = Duration(hours: 2);

  /// Cho phép Check In sớm tối đa bao lâu trước giờ bắt đầu ca (đã chốt).
  static const _checkInEarlyWindow = Duration(minutes: 60);

  /// Đọc cài đặt công ty
  Future<CompanySettingsModel>
  getCompanySettings() async {
    final doc = await _db
        .collection('company_settings')
        .doc(
      AppConfig.companySettingsDocId,
    )
        .get();

    if (!doc.exists) {
      throw Exception(
        'Không tìm thấy cấu hình công ty',
      );
    }

    return CompanySettingsModel
        .fromFirestore(doc);
  }

  /// Check In
  Future<void> checkIn() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    /// Toàn bộ phần thân bên dưới (GPS, đọc company_settings/users, và
    /// transaction) được bọc chung 1 try/catch cho FirebaseException — mất
    /// mạng có thể khiến BẤT KỲ lượt đọc/ghi Firestore nào ở đây thất bại,
    /// không chỉ riêng transaction, nên cần bắt ở phạm vi đủ rộng để luôn
    /// hiện đúng 1 thông báo nghiệp vụ nhất quán thay vì lộ lỗi kỹ thuật thô
    /// tuỳ theo bước nào thất bại trước. Các exception nghiệp vụ khác (ngoài
    /// bán kính, chưa tới giờ, đã Check In rồi...) đều là Exception thường,
    /// không phải FirebaseException, nên không bị ảnh hưởng bởi khối này.
    try {
    final position =
    await _gpsService
        .getCurrentPosition();

    final settings =
    await getCompanySettings();

    final distance =
    _gpsService.calculateDistance(
      currentLat: position.latitude,
      currentLng: position.longitude,
      companyLat: settings.latitude,
      companyLng: settings.longitude,
    );

    if (!_gpsService.isWithinRadius(
      distance: distance,
      radius: settings.radius,
    )) {
      throw Exception(
        'Bạn đang ở ngoài phạm vi công ty.\n'
            'Khoảng cách hiện tại: '
            '${distance.toStringAsFixed(0)}m\n'
            'Bán kính cho phép: '
            '${settings.radius.toStringAsFixed(0)}m',
      );
    }

    /// Lấy user info (cần shiftGroup để xác định Business Date/Shift)
    final userDoc = await _db
        .collection('users')
        .doc(user.uid)
        .get();

    final userData =
        userDoc.data() ?? {};
    if (userData.isEmpty) {
      throw Exception(
        'Không tìm thấy thông tin nhân viên',
      );
    }

    final employeeCode =
        userData['employeeCode'] ?? '';

    final shiftGroup =
        userData['shiftGroup'] ?? 'A';

    final now = ClockService.now();

    /// Bước 1: Business Date
    final businessDate = BusinessDateHelper.resolveBusinessDate(
      now,
      settings,
      shiftGroup,
    );

    /// Bước 2: Shift (tính trên Business Date, không phải ngày lịch hiện tại)
    final currentShift = settings.getCurrentShift(
      shiftGroup: shiftGroup,
      today: businessDate,
    );

    final docId =
        '${DateHelper.toDateString(businessDate)}_${user.uid}';

    /// Bước 3: Shift Window
    final window = BusinessDateHelper.resolveShiftWindow(
      businessDate,
      currentShift,
      settings,
    );

    /// Bước 4: đã tới giờ Check In chưa (cho phép sớm tối đa 60 phút)
    final earliestCheckIn = window.start.subtract(_checkInEarlyWindow);
    if (now.isBefore(earliestCheckIn)) {
      throw Exception(
        'Chưa tới giờ Check In.\n'
        'Ca làm việc bắt đầu lúc ${DateHelper.toTimeString(window.start)}, '
        'bạn có thể Check In sớm nhất từ '
        '${DateHelper.toTimeString(earliestCheckIn)} (trước giờ vào ca 1 tiếng).',
      );
    }

    /// Bước 5: đã quá giờ chưa (vắng mặt)
    if (now.isAfter(window.end)) {
      throw Exception(
        'Ca làm việc đã kết thúc (${DateHelper.toTimeString(window.end)}).\n'
        'Ngày hôm nay được tính là vắng mặt.',
      );
    }

    /// Bước 7: Tính đi muộn
    final isLate = settings.calculateIsLate(
      checkInTime: now,
      window: window,
    );

    /// Bước 8/9: đọc "đã Check In chưa" + ghi document trong cùng 1
    /// transaction, để tránh race condition khi checkIn() bị gọi trùng lặp
    /// gần như đồng thời (double tap, 2 phiên cùng lúc...) — xem
    /// docs/decision/01_DECISION_LOG.md. Firestore sẽ tự động retry lại hàm
    /// transaction khi phát hiện xung đột ghi, nên đúng 1 trong các lần gọi
    /// trùng sẽ thắng; các lần còn lại đọc lại thấy document đã tồn tại và
    /// nhận đúng lỗi nghiệp vụ bên dưới thay vì âm thầm ghi đè dữ liệu.
    final docRef = _db.collection('attendance').doc(docId);

    await _db.runTransaction((transaction) async {
      final existing = await transaction.get(docRef);

      if (existing.exists) {
        throw Exception(
          'Bạn đã Check In hôm nay rồi',
        );
      }

      transaction.set(docRef, {
        'uid': user.uid,
        'employeeCode': employeeCode,
        'shift': currentShift,
        'attendanceDate': Timestamp.fromDate(businessDate),
        'checkIn': Timestamp.fromDate(now),
        'checkOut': null,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'distance': distance,
        'checkOutLatitude': null,
        'checkOutLongitude': null,
        'workHours': null,
        'isLate': isLate,
        'status': isLate ? 'late' : 'on_time',
        'createdAt': Timestamp.fromDate(now),
      });
    });
    } on FirebaseException catch (e, st) {
      AppLogger.error('AttendanceRepository.checkIn', e, st);
      /// Transaction/đọc Firestore không dùng được hàng đợi ghi khi offline
      /// (khác set()/update() thường) — cố ý, để không chốt giờ Check In tại
      /// một thời điểm rồi ghi lên server ở một thời điểm khác. `e.code` là
      /// mã lỗi có cấu trúc do Firebase SDK định nghĩa, không phải so khớp
      /// chuỗi lỗi hiển thị (khác cách làm đã bị REVIEW.md mục 8.2 phê bình).
      if (e.code == 'unavailable') {
        throw Exception(
          'Không có kết nối Internet. Vui lòng kết nối mạng trước khi Check In.',
        );
      }
      rethrow;
    }
  }

  /// Lấy attendance của ngày làm việc hiện tại (Business Date, không phải
  /// ngày lịch) cho user đang đăng nhập.
  Future<AttendanceModel?>
  getTodayAttendance() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final settings = await getCompanySettings();

    final userDoc = await _db
        .collection('users')
        .doc(user.uid)
        .get();

    final shiftGroup =
        userDoc.data()?['shiftGroup'] ?? 'A';

    final businessDate = BusinessDateHelper.resolveBusinessDate(
      ClockService.now(),
      settings,
      shiftGroup,
    );

    final docId =
        '${DateHelper.toDateString(businessDate)}_${user.uid}';

    final doc = await _db
        .collection('attendance')
        .doc(docId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return AttendanceModel
        .fromFirestore(doc);
  }

  /// Lấy tất cả lịch sử chấm công của user
  Future<List<AttendanceModel>> getAllAttendance() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _db
        .collection('attendance')
        .where('uid', isEqualTo: user.uid)
        .orderBy('attendanceDate', descending: true)
        .get();

    final List<AttendanceModel> records = [];
    for (final doc in snapshot.docs) {
      try {
        records.add(AttendanceModel.fromFirestore(doc));
      } catch (e) {
        // Bỏ qua document lỗi để không làm crash toàn bộ danh sách lịch sử.
        debugPrint('Bỏ qua document attendance lỗi (${doc.id}): $e');
      }
    }
    return records;
  }

  /// Check Out — tìm đúng document đã tạo lúc Check In (kể cả khi Check Out
  /// muộn sau nửa đêm/qua giờ tan ca, trong khung ân hạn 2 giờ).
  Future<void> checkOut() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    final settings = await getCompanySettings();

    final userDoc = await _db
        .collection('users')
        .doc(user.uid)
        .get();

    final shiftGroup =
        userDoc.data()?['shiftGroup'] ?? 'A';

    final now = ClockService.now();

    /// Bước 1: Business Date candidate (giống hệt CheckIn/Home)
    final candidate = BusinessDateHelper.resolveBusinessDate(
      now,
      settings,
      shiftGroup,
    );

    String? targetDocId;
    Map<String, dynamic>? targetData;

    final candidateDocId =
        '${DateHelper.toDateString(candidate)}_${user.uid}';

    final candidateDoc = await _db
        .collection('attendance')
        .doc(candidateDocId)
        .get();

    if (candidateDoc.exists) {
      final data = candidateDoc.data()!;
      if (data['checkOut'] != null) {
        throw Exception(
          'Bạn đã Check Out hôm nay rồi',
        );
      }
      targetDocId = candidateDocId;
      targetData = data;
    } else {
      /// Business Date không rollback (candidate == hôm nay theo lịch) ->
      /// thử document của HÔM QUA, trong khung ân hạn 2 giờ sau giờ tan ca
      /// (Check Out muộn cho ca đêm — xem ATTENDANCE_BUSINESS_FLOW.md mục 2).
      final today = DateTime(now.year, now.month, now.day);

      if (candidate == today) {
        final yesterday = today.subtract(const Duration(days: 1));

        final yesterdayDocId =
            '${DateHelper.toDateString(yesterday)}_${user.uid}';

        final yesterdayDoc = await _db
            .collection('attendance')
            .doc(yesterdayDocId)
            .get();

        if (yesterdayDoc.exists) {
          final data = yesterdayDoc.data()!;
          final shift = data['shift'] ?? 'day';

          if (data['checkOut'] == null && shift == 'night') {
            final yesterdayWindow = BusinessDateHelper.resolveShiftWindow(
              yesterday,
              shift,
              settings,
            );

            final graceDeadline =
                yesterdayWindow.end.add(_checkOutGracePeriod);

            if (!now.isAfter(graceDeadline)) {
              targetDocId = yesterdayDocId;
              targetData = data;
            }
          }
        }
      }
    }

    if (targetDocId == null || targetData == null) {
      throw Exception(
        'Không tìm thấy ca làm việc cần Check Out hợp lệ.\n'
        'Vui lòng liên hệ quản lý/admin để được hỗ trợ điều chỉnh chấm công.',
      );
    }

    final position =
    await _gpsService
        .getCurrentPosition();

    final distance =
    _gpsService.calculateDistance(
      currentLat: position.latitude,
      currentLng: position.longitude,
      companyLat: settings.latitude,
      companyLng: settings.longitude,
    );

    if (!_gpsService.isWithinRadius(
      distance: distance,
      radius: settings.radius,
    )) {
      throw Exception(
        'Bạn đang ở ngoài phạm vi công ty.\n'
            'Khoảng cách hiện tại: '
            '${distance.toStringAsFixed(0)}m\n'
            'Bán kính cho phép: '
            '${settings.radius.toStringAsFixed(0)}m',
      );
    }

    final checkIn =
    (targetData['checkIn']
    as Timestamp)
        .toDate();

    final workHours =
        now
            .difference(checkIn)
            .inMinutes /
            60;

    final attendanceDate =
    (targetData['attendanceDate']
    as Timestamp)
        .toDate();

    final shift =
        targetData['shift'] ?? 'day';

    /// Shift Window của đúng document tìm được (dùng attendanceDate + shift
    /// đã lưu sẵn, không tính lại theo ngày hiện tại).
    final window = BusinessDateHelper.resolveShiftWindow(
      attendanceDate,
      shift,
      settings,
    );

    final isEarlyLeave =
    settings.calculateEarlyLeave(
      checkOutTime: now,
      window: window,
    );

    await _db
        .collection('attendance')
        .doc(targetDocId)
        .update({
      'checkOut':
      Timestamp.fromDate(now),

      'checkOutLatitude':
      position.latitude,

      'checkOutLongitude':
      position.longitude,

      'workHours': workHours,

      'isEarlyLeave': isEarlyLeave,

      'status': 'completed',

      'updatedAt':
      Timestamp.fromDate(now),
    });
  }
}
