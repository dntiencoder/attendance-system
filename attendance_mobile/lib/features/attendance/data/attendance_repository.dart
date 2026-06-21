import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/attendance_model.dart';
import '../../../services/gps_service.dart';
import '../../../features/settings/domain/company_settings_model.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/utils/date_helper.dart';

class AttendanceRepository {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final GpsService _gpsService =
  GpsService();

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

    final now = DateTime.now();

    final today =
    DateHelper.toDateString(now);

    final docId =
        '${today}_${user.uid}';

    final existing = await _db
        .collection('attendance')
        .doc(docId)
        .get();

    if (existing.exists) {
      throw Exception(
        'Bạn đã Check In hôm nay rồi',
      );
    }

    /// Lấy user info
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

    /// Xác định ca hiện tại
    final currentShift =
    settings.getCurrentShift(
      shiftGroup: shiftGroup,
      today: now,
    );

    /// Tính đi muộn
    final isLate =
    settings.calculateIsLate(
      checkInTime: now,
      shift: currentShift,
    );

    await _db
        .collection('attendance')
        .doc(docId)
        .set({
      'uid': user.uid,

      'employeeCode':
      employeeCode,

      'shift':
      currentShift,

      'attendanceDate':
      Timestamp.fromDate(
        DateTime(
          now.year,
          now.month,
          now.day,
        ),
      ),

      'checkIn':
      Timestamp.fromDate(now),

      'checkOut': null,

      'latitude':
      position.latitude,

      'longitude':
      position.longitude,

      'distance': distance,

      'checkOutLatitude': null,

      'checkOutLongitude': null,

      'workHours': null,

      'isLate': isLate,

      'status':
      isLate
          ? 'late'
          : 'on_time',

      'createdAt':
      Timestamp.fromDate(now),
    });
  }

  /// Lấy attendance hôm nay
  Future<AttendanceModel?>
  getTodayAttendance() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final today =
    DateHelper.toDateString(
      DateTime.now(),
    );

    final docId =
        '${today}_${user.uid}';

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

  /// Check Out
  Future<void> checkOut() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    final today =
    DateHelper.toDateString(
      DateTime.now(),
    );

    final docId =
        '${today}_${user.uid}';

    final existing = await _db
        .collection('attendance')
        .doc(docId)
        .get();

    if (!existing.exists) {
      throw Exception(
        'Bạn chưa Check In hôm nay',
      );
    }

    final data =
    existing.data()!;

    if (data['checkOut'] != null) {
      throw Exception(
        'Bạn đã Check Out hôm nay rồi',
      );
    }

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

    final now = DateTime.now();

    final checkIn =
    (data['checkIn']
    as Timestamp)
        .toDate();

    final workHours =
        now
            .difference(checkIn)
            .inMinutes /
            60;

// Lấy ca hiện tại
    final shift =
        data['shift'] ?? 'day';

// Kiểm tra về sớm
    final isEarlyLeave =
    settings.calculateEarlyLeave(
      checkOutTime: now,
      shift: shift,
    );

    await _db
        .collection('attendance')
        .doc(docId)
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