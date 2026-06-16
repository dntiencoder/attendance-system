import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/attendance_model.dart';
import '../../../services/gps_service.dart';
import '../../../features/settings/domain/company_settings_model.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/utils/date_helper.dart';

class AttendanceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GpsService _gpsService = GpsService();

  // Đọc cài đặt công ty
  Future<CompanySettingsModel> getCompanySettings() async {
    final doc = await _db
        .collection('company_settings')
        .doc(AppConfig.companySettingsDocId)
        .get();

    return CompanySettingsModel.fromFirestore(doc);
  }

  // Check In
  Future<void> checkIn() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    // GPS hiện tại
    final position =
    await _gpsService.getCurrentPosition();

    // Cài đặt công ty
    final settings =
    await getCompanySettings();

    // Tính khoảng cách
    final distance =
    _gpsService.calculateDistance(
      currentLat: position.latitude,
      currentLng: position.longitude,
      companyLat: settings.latitude,
      companyLng: settings.longitude,
    );

    // Kiểm tra bán kính
    if (!_gpsService.isWithinRadius(
      distance: distance,
      radius: settings.radius,
    )) {
      throw Exception(
        'Bạn đang ở ngoài phạm vi công ty.\n'
            'Khoảng cách hiện tại: ${distance.toStringAsFixed(0)}m\n'
            'Bán kính cho phép: ${settings.radius.toStringAsFixed(0)}m',
      );
    }

    final now = DateTime.now();
    final today =
    DateHelper.toDateString(now);

    final docId =
        '${today}_${user.uid}';

    // Kiểm tra đã Check In chưa
    final existing = await _db
        .collection('attendance')
        .doc(docId)
        .get();

    if (existing.exists) {
      throw Exception(
        'Bạn đã Check In hôm nay rồi',
      );
    }

    // Tính đi muộn
    final isLate =
    settings.calculateIsLate(now);

    // Lấy employeeCode
    final userDoc = await _db
        .collection('users')
        .doc(user.uid)
        .get();

    final employeeCode =
        userDoc.data()?['employeeCode'] ?? '';

    // Lưu Firestore
    await _db
        .collection('attendance')
        .doc(docId)
        .set({
      'uid': user.uid,
      'employeeCode': employeeCode,

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

      'isLate': isLate,

      'status':
      isLate
          ? 'late'
          : 'on_time',

      'createdAt':
      Timestamp.fromDate(now),
    });
  }

  // Lấy dữ liệu hôm nay
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

    return AttendanceModel.fromFirestore(
      doc,
    );
  }

  // Check Out
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

    // GPS hiện tại
    final position =
    await _gpsService.getCurrentPosition();

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
            'Khoảng cách: ${distance.toStringAsFixed(0)}m\n'
            'Bán kính: ${settings.radius.toStringAsFixed(0)}m',
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

      'status': 'completed',
    });
  }
}