import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/settings/domain/company_settings_model.dart';

class SeedFirestore {
  static Future<void> seed() async {
    final db = FirebaseFirestore.instance;

    // UID của tài khoản bạn dùng để đăng nhập demo
    const employeeUid = '7VtAl9r6rcRgBGLXcVTtUcNn05l2';
    const adminUid = 'UqyJA2oAr6VzjrOeAUkZRJXRAgh2';

    print('Đang chuẩn bị dọn dẹp và nạp dữ liệu Demo chuẩn UMC...');

    final batch = db.batch();

    // 1. Cấu hình Công ty (08:00 - 20:00)
    final rotationStart = DateTime(2026, 6, 1);
    final settings = CompanySettingsModel(
      id: 'main',
      companyName: 'UMC Việt Nam',
      latitude: 21.0285, 
      longitude: 105.7848,
      radius: 500.0,
      dayShiftStart: '08:00',
      dayShiftEnd: '20:00',
      nightShiftStart: '20:00',
      nightShiftEnd: '08:00',
      rotationDays: 14,
      rotationStartDate: rotationStart,
      updatedAt: DateTime.now(),
    );

    batch.set(db.collection('company_settings').doc('main'), settings.toFirestore());

    // 2. Danh sách Phòng ban
    final departments = {
      'dep001': 'Phòng Kỹ thuật',
      'dep002': 'Phòng Nhân sự',
      'dep003': 'Xưởng Sản xuất',
    };
    for (var entry in departments.entries) {
      batch.set(db.collection('departments').doc(entry.key), {
        'name': entry.value,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // 3. Thông tin người dùng Demo
    const shiftGroup = 'B'; // Nhóm B (01/06-14/06 làm ca Ngày)
    
    // Thêm Nhân viên
    batch.set(db.collection('users').doc(employeeUid), {
      'employeeCode': 'EMP001',
      'name': 'Danh Nhật Tiến',
      'email': 'danhnhattien284@gmail.com',
      'role': 'employee',
      'shiftGroup': shiftGroup,
      'departmentId': 'dep001',
      'phone': '0901234567',
      'avatarUrl': '',
      'isActive': true,
      'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
    });

    // Thêm Admin
    batch.set(db.collection('users').doc(adminUid), {
      'employeeCode': 'ADMIN001',
      'name': 'Quản trị viên UMC',
      'email': 'admin@gmail.com', // Thay bằng email admin thực tế của bạn
      'role': 'admin',
      'shiftGroup': 'A',
      'departmentId': 'dep001',
      'phone': '0909999999',
      'avatarUrl': '',
      'isActive': true,
      'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
    });

    // 4. DỮ LIỆU CHẤM CÔNG PHONG PHÚ (Tháng 06/2026)
    // Tự động xác định ca theo ngày để demo chính xác
    final List<Map<String, dynamic>> records = [
      {'d': 1, 'in': '07:55', 'out': '20:05', 'status': 'completed', 'late': false, 'early': false},
      {'d': 2, 'in': '08:15', 'out': '20:00', 'status': 'late', 'late': true, 'early': false},
      {'d': 3, 'in': '07:50', 'out': '19:30', 'status': 'early_leave', 'late': false, 'early': true},
      {'d': 4, 'in': '07:58', 'out': '20:10', 'status': 'completed', 'late': false, 'early': false},
      {'d': 5, 'in': '08:20', 'out': '19:15', 'status': 'late', 'late': true, 'early': true},
      {'d': 8, 'in': '07:55', 'out': '20:05', 'status': 'completed', 'late': false, 'early': false},
      {'d': 9, 'in': '08:10', 'out': '20:00', 'status': 'late', 'late': true, 'early': false},
      // Bắt đầu chu kỳ 2 (Đổi ca) từ ngày 15/06
      {'d': 15, 'in': '19:55', 'out': '08:05', 'status': 'completed', 'late': false, 'early': false, 'isNextDay': true},
      {'d': 16, 'in': '20:20', 'out': '08:00', 'status': 'late', 'late': true, 'early': false, 'isNextDay': true},
    ];

    for (var r in records) {
      final day = r['d'] as int;
      final date = DateTime(2026, 6, day);
      
      // TỰ ĐỘNG XÁC ĐỊNH CA THEO LOGIC CHUẨN
      final shift = settings.getCurrentShift(shiftGroup: shiftGroup, today: date);
      
      final checkInTime = _parseTime(date, r['in'] as String);
      final checkOutTime = _parseTime(date, r['out'] as String, isNextDay: r['isNextDay'] == true);
      
      final docId = '2026-06-${day.toString().padLeft(2, '0')}_$employeeUid';
      batch.set(db.collection('attendance').doc(docId), {
        'uid': employeeUid,
        'employeeCode': 'EMP001',
        'shift': shift,
        'attendanceDate': Timestamp.fromDate(date),
        'checkIn': Timestamp.fromDate(checkInTime),
        'checkOut': Timestamp.fromDate(checkOutTime),
        'latitude': 21.0285,
        'longitude': 105.7848,
        'distance': 15.0,
        'workHours': 12.0,
        'isLate': r['late'],
        'isEarlyLeave': r['early'],
        'status': r['status'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Đánh dấu đã seed thành công
    batch.set(db.collection('dev_metadata').doc('seed'), {
      'seeded': true,
      'seededAt': FieldValue.serverTimestamp(),
      'version': 'full_v2' // Đổi version để ghi đè nếu cần
    });

    await batch.commit();
    print('Nạp 100% dữ liệu Demo thành công! Hãy mở App tháng 06/2026.');
  }

  static DateTime _parseTime(DateTime base, String timeStr, {bool isNextDay = false}) {
    final parts = timeStr.split(':');
    final dt = DateTime(base.year, base.month, base.day, int.parse(parts[0]), int.parse(parts[1]));
    return isNextDay ? dt.add(const Duration(days: 1)) : dt;
  }
}
