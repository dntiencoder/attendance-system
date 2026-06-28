import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/settings/domain/company_settings_model.dart';
import 'dart:math';

class DemoSeeder {
  static Future<void> cleanAndSeed() async {
    final db = FirebaseFirestore.instance;
    print('🚀 Bắt đầu dọn dẹp và nạp dữ liệu Demo sạch...');

    // 1. Thông tin tài khoản
    final users = [
      {
        'uid': '4Znnqs0bxiXbFeYimTQ5znDL5dG3',
        'email': 'shiroyasha284@gmail.com',
        'name': 'Trần Văn A',
        'role': 'employee',
        'shiftGroup': 'A',
        'employeeCode': 'EMP001',
      },
      {
        'uid': 'Nuav1I87ZOg1M0AysReIoaeUv2C2',
        'email': 'dntienktpm2211046@student.ctuet.edu.vn',
        'name': 'Lê Thị B',
        'role': 'employee',
        'shiftGroup': 'B',
        'employeeCode': 'EMP002',
      },
      {
        'uid': '7VtAl9r6rcRgBGLXcVTtUcNn05l2',
        'email': 'danhnhattien284@gmail.com',
        'name': 'Danh Nhật Tiến',
        'role': 'employee',
        'shiftGroup': 'B',
        'employeeCode': 'EMP003',
      },
      {
        'uid': 'UqyJA2oAr6VzjrOeAUkZRJXRAgh2',
        'email': 'admin@gmail.com',
        'name': 'Quản trị viên UMC',
        'role': 'admin',
        'shiftGroup': 'A',
        'employeeCode': 'ADMIN001',
      },
    ];

    final batch = db.batch();

    // 2. Cấu hình Công ty (Cần để tính toán ca)
    final rotationStart = DateTime(2026, 6, 1); // Cố định để demo ổn định
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

    // 3. Nạp người dùng (Kiểm tra và giữ lại avatarUrl nếu đã có trên Firebase)
    for (var u in users) {
      final userDoc = await db.collection('users').doc(u['uid'] as String).get();
      String existingAvatar = '';
      
      if (userDoc.exists) {
        final data = userDoc.data();
        existingAvatar = data?['avatarUrl'] ?? '';
      }

      // Nếu avatarUrl hiện tại chứa 'ibb.co' mà không có 'i.ibb.co', nó có thể là link lỗi
      // Nhưng để an toàn cho demo, ta chỉ giữ lại nếu nó có vẻ là link ảnh trực tiếp
      // hoặc đơn giản là để người dùng tự sửa trên Web và Seeder không ghi đè.

      batch.set(db.collection('users').doc(u['uid'] as String), {
        'employeeCode': u['employeeCode'],
        'name': u['name'],
        'email': u['email'],
        'role': u['role'],
        'shiftGroup': u['shiftGroup'],
        'departmentId': 'dep001',
        'phone': '0901234567',
        'avatarUrl': existingAvatar, 
        'isActive': true,
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });
    }

    // 3.1 Ghi đè flag để không chạy Seeder ở các lần sau (tránh ghi đè dữ liệu mới)
    batch.set(db.collection('dev_metadata').doc('seed_info'), {
      'seededAt': Timestamp.now(),
      'status': 'completed',
    });

    // 3.1 Nạp Departments (để profile hiện tên phòng ban thay vì ID)
    batch.set(db.collection('departments').doc('dep001'), {
      'name': 'Phòng Kỹ thuật',
      'managerUid': 'UqyJA2oAr6VzjrOeAUkZRJXRAgh2',
      'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
    });

    // 4. Tạo 2 tuần dữ liệu (14 ngày qua)
    final now = DateTime.now();
    final random = Random();

    for (int i = 0; i < 14; i++) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final weekday = date.weekday; // 1: Mon, ..., 6: Sat, 7: Sun

      // Tính toán thông tin chu kỳ
      final daysPassed = DateTime(date.year, date.month, date.day)
          .difference(DateTime(rotationStart.year, rotationStart.month, rotationStart.day))
          .inDays;
      
      // rotationIndex: khối 14 ngày (0, 1, 2...)
      final rotationIndex = (daysPassed / 14).floor();
      // Tuần trong chu kỳ 14 ngày (0: tuần đầu, 1: tuần chuyển giao)
      final weekInRotation = ((daysPassed % 14) / 7).floor();
      final isRotationWeek = weekInRotation == 1;

      for (var u in users) {
        if (u['role'] == 'admin') continue;

        final uid = u['uid'] as String;
        final shiftGroup = u['shiftGroup'] as String;
        final employeeCode = u['employeeCode'] as String;
        
        // 4.1 Áp dụng logic nghỉ cuối tuần theo yêu cầu UMC
        // Tuần chuyển giao (isRotationWeek == true): Làm tới thứ 6, T7 tăng ca, CN nghỉ tuyệt đối
        // Tuần bình thường (isRotationWeek == false): Làm tới thứ 7, CN tăng ca (tùy chọn)
        
        bool isWorkDay = true;
        bool isOTDay = false;

        if (isRotationWeek) {
          if (weekday == 7) isWorkDay = false; // CN nghỉ tuyệt đối
          if (weekday == 6) isOTDay = true;    // T7 là ngày tăng ca
        } else {
          if (weekday == 7) {
            isWorkDay = false;
            isOTDay = true; // CN là ngày tăng ca (ngẫu nhiên có hoặc không)
          }
        }

        // Quyết định có tạo record không
        // 3: Nghỉ (không có record)
        int scenario = random.nextInt(7); 

        // Logic ngày nghỉ: 
        // Nếu không phải ngày làm việc và không chọn làm OT -> Skip
        if (!isWorkDay) {
          if (!isOTDay || random.nextBool()) continue; 
        }
        
        // Nếu là ngày làm việc bình thường nhưng ngẫu nhiên "nghỉ" (scenario 3) -> Skip
        if (isWorkDay && scenario == 3 && i != 0) continue;

        if (i == 0) scenario = 5; // Hôm nay để "Đang làm việc" hoặc "Hoàn thành"

        // Xác định ca theo logic settings
        final shift = settings.getCurrentShift(shiftGroup: shiftGroup, today: date);
        final isDay = shift == 'day';

        DateTime checkIn;
        DateTime? checkOut;
        String status = 'completed';
        bool isLate = false;
        bool isEarlyLeave = false;

        final startHour = isDay ? 8 : 20;
        final endHour = isDay ? 20 : 8;

        // Xử lý Check-in
        if (scenario == 1 || scenario == 4) {
          // Muộn
          checkIn = DateTime(date.year, date.month, date.day, startHour, 15 + random.nextInt(30));
          isLate = true;
          status = 'late';
        } else {
          // Đúng giờ
          checkIn = DateTime(date.year, date.month, date.day, startHour - 1, 45 + random.nextInt(15));
        }

        // Xử lý Check-out
        if (scenario == 5 && i == 0) {
          // Đang làm việc (chưa check-out)
          checkOut = null;
          status = isLate ? 'late' : 'on_time';
        } else if (scenario == 2 || scenario == 4) {
          // Về sớm
          final checkoutDate = !isDay ? date.add(const Duration(days: 1)) : date;
          checkOut = DateTime(checkoutDate.year, checkoutDate.month, checkoutDate.day, endHour - 1, 30 + random.nextInt(20));
          isEarlyLeave = true;
          status = (scenario == 4) ? 'late' : 'early_leave';
        } else {
          // Hoàn thành tốt
          final checkoutDate = !isDay ? date.add(const Duration(days: 1)) : date;
          checkOut = DateTime(checkoutDate.year, checkoutDate.month, checkoutDate.day, endHour, random.nextInt(15));
        }

        final docId = '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}_$uid';
        
        batch.set(db.collection('attendance').doc(docId), {
          'uid': uid,
          'employeeCode': employeeCode,
          'shift': shift,
          'attendanceDate': Timestamp.fromDate(date),
          'checkIn': Timestamp.fromDate(checkIn),
          'checkOut': checkOut != null ? Timestamp.fromDate(checkOut) : null,
          'latitude': 21.0285,
          'longitude': 105.7848,
          'distance': 10.0 + random.nextDouble() * 20,
          'workHours': checkOut != null ? checkOut.difference(checkIn).inMinutes / 60.0 : 0.0,
          'isLate': isLate,
          'isEarlyLeave': isEarlyLeave,
          'status': status,
          'createdAt': Timestamp.fromDate(date),
        });
      }
    }

    await batch.commit();
    print('✅ Nạp dữ liệu Demo thành công cho 3 nhân viên!');
    print('1. shiroyasha284@gmail.com (Nhóm A)');
    print('2. dntienktpm2211046@student.ctuet.edu.vn (Nhóm B)');
    print('3. danhnhattien284@gmail.com (Nhóm B - Danh Nhật Tiến)');
  }
}
