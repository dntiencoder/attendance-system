import 'package:cloud_firestore/cloud_firestore.dart';

class SeedFirestore {
  static Future<void> seed() async {
    final db = FirebaseFirestore.instance;

    const adminUid = 'UqyJA2oAr6VzjrOeAUkZRJXRAgh2';
    const employeeUid = 'QDPeNJaIhZVsNgkw8Bntw7DjjxE3';

    final seedCheck =
    await db.collection('dev_metadata').doc('seed').get();

    if (seedCheck.exists) {
      print('Firestore already seeded, skipping...');
      return;
    }

    final now = Timestamp.now();

    final batch = db.batch();

    // ==========================
    // COMPANY SETTINGS
    // ==========================
    batch.set(
      db.collection('company_settings').doc('main'),
      {
        'companyName': 'GPS Attendance System',

        'latitude': 10.7769,
        'longitude': 106.7009,

        'radius': 9999999,

        // Ca ngày
        'dayShiftStart': '08:00',
        'dayShiftEnd': '20:00',

        // Ca đêm
        'nightShiftStart': '20:00',
        'nightShiftEnd': '08:00',

        // Đổi ca mỗi 14 ngày
        'rotationDays': 14,

        'rotationStartDate':
        Timestamp.fromDate(
          DateTime(2026, 6, 1),
        ),

        'updatedAt': now,
      },
    );

    // ==========================
    // DEPARTMENTS
    // ==========================
    batch.set(
      db.collection('departments').doc('dep001'),
      {
        'name': 'Phòng Kỹ thuật',
        'managerUid': adminUid,
        'createdAt': now,
      },
    );

    batch.set(
      db.collection('departments').doc('dep002'),
      {
        'name': 'Phòng Nhân sự',
        'managerUid': '',
        'createdAt': now,
      },
    );

    // ==========================
    // ADMIN USER
    // ==========================
    batch.set(
      db.collection('users').doc(adminUid),
      {
        'employeeCode': 'ADMIN001',
        'name': 'Administrator',
        'email': 'admin@gmail.com',

        'role': 'admin',

        'shiftGroup': 'A',

        'departmentId': 'dep001',
        'phone': '0900000000',
        'avatarUrl': '',

        'isActive': true,

        'createdAt': now,
      },
    );

    // ==========================
    // EMPLOYEE USER
    // ==========================
    batch.set(
      db.collection('users').doc(employeeUid),
      {
        'employeeCode': 'EMP001',
        'name': 'Danh Nhật Tiến',
        'email': 'danhnhattien284@gmail.com',

        'role': 'employee',

        'shiftGroup': 'B',

        'departmentId': 'dep001',
        'phone': '0901234567',
        'avatarUrl': '',

        'isActive': true,

        'createdAt': now,
      },
    );

    // ==========================
    // ATTENDANCE DEMO
    // ==========================
    batch.set(
      db
          .collection('attendance')
          .doc('2026-06-09_$employeeUid'),
      {
        'uid': employeeUid,

        'employeeCode': 'EMP001',

        'shift': 'day',

        'attendanceDate': now,

        'checkIn': now,

        'checkOut': null,

        'latitude': 10.7769,
        'longitude': 106.7009,

        'distance': 20.5,

        'checkOutLatitude': null,
        'checkOutLongitude': null,

        'workHours': null,

        'isLate': false,

        'status': 'on_time',

        'createdAt': now,
      },
    );

    // ==========================
    // LEAVE REQUEST DEMO
    // ==========================
    batch.set(
      db
          .collection('leave_requests')
          .doc('leave_demo_001'),
      {
        'uid': employeeUid,

        'employeeCode': 'EMP001',

        'startDate': now,
        'endDate': now,

        'reason': 'Việc gia đình',

        'status': 'pending',

        'adminNote': '',

        'createdAt': now,
        'updatedAt': now,
      },
    );

    // ==========================
    // NOTIFICATION DEMO
    // ==========================
    batch.set(
      db
          .collection('notifications')
          .doc('notification_demo_001'),
      {
        'uid': employeeUid,

        'title': 'Chào mừng',

        'body':
        'Tài khoản đã được tạo thành công',

        'type': 'system',

        'isRead': false,

        'createdAt': now,
      },
    );

    // ==========================
    // DEV METADATA
    // ==========================
    batch.set(
      db.collection('dev_metadata').doc('seed'),
      {
        'seeded': true,
        'seededAt': now,
      },
    );

    await batch.commit();

    print('Firestore seeded successfully!');
  }
}