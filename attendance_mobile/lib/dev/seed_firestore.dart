import 'package:cloud_firestore/cloud_firestore.dart';

class SeedFirestore {
  static Future<void> seed() async {
    final db = FirebaseFirestore.instance;

    const adminUid = 'UqyJA2oAr6VzjrOeAUkZRJXRAgh2';
    const employeeUid = 'oopclR7cZgTMMzS5XglApUu9Lu33';

    final seedCheck = await db.collection('dev_metadata').doc('seed').get();

    if (seedCheck.exists) {
      print('Firestore already seeded, skipping...');
      return;
    }

    final now = Timestamp.now();
    final batch = db.batch();

    batch.set(db.collection('company_settings').doc('main'), {
      'companyName': 'GPS Attendance System',
      'latitude': 10.7769,
      'longitude': 106.7009,
      'radius': 100,
      'workStartTime': '08:00',
      'workEndTime': '17:00',
      'updatedAt': now,
    });

    batch.set(db.collection('departments').doc('dep001'), {
      'name': 'Phòng Kỹ thuật',
      'managerUid': adminUid,
      'createdAt': now,
    });

    batch.set(db.collection('departments').doc('dep002'), {
      'name': 'Phòng Nhân sự',
      'managerUid': '',
      'createdAt': now,
    });

    batch.set(db.collection('users').doc(adminUid), {
      'employeeCode': 'ADMIN001',
      'name': 'Administrator',
      'email': 'admin@gmail.com',
      'role': 'admin',
      'departmentId': 'dep001',
      'phone': '0900000000',
      'avatarUrl': '',
      'isActive': true,
      'createdAt': now,
    });

    batch.set(db.collection('users').doc(employeeUid), {
      'employeeCode': 'EMP001',
      'name': 'Nguyễn Văn A',
      'email': 'employee@gmail.com',
      'role': 'employee',
      'departmentId': 'dep001',
      'phone': '0901234567',
      'avatarUrl': '',
      'isActive': true,
      'createdAt': now,
    });

    batch.set(db.collection('attendance').doc('2026-06-09_EMP001'), {
      'uid': employeeUid,
      'employeeCode': 'EMP001',
      'attendanceDate': now,
      'checkIn': now,
      'checkOut': null,
      'latitude': 10.7769,
      'longitude': 106.7009,
      'distance': 20.5,
      'isLate': false,
      'status': 'on_time',
      'createdAt': now,
    });

    batch.set(db.collection('leave_requests').doc('leave_demo_001'), {
      'uid': employeeUid,
      'employeeCode': 'EMP001',
      'startDate': now,
      'endDate': now,
      'reason': 'Việc gia đình',
      'status': 'pending',
      'adminNote': '',
      'createdAt': now,
      'updatedAt': now,
    });

    batch.set(db.collection('notifications').doc('notification_demo_001'), {
      'uid': employeeUid,
      'title': 'Chào mừng',
      'body': 'Tài khoản đã được tạo thành công',
      'type': 'system',
      'isRead': false,
      'createdAt': now,
    });

    batch.set(db.collection('dev_metadata').doc('seed'), {
      'seeded': true,
      'seededAt': now,
    });

    await batch.commit();

    print('Firestore seeded successfully!');
  }
}