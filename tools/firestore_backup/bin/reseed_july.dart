// Script one-off: tạo lại dữ liệu sạch cho tháng 7/2026 sau khi đã xoá toàn
// bộ users/departments/attendance/leave_requests/notifications (xem
// docs/project/01_BACKLOG.md mục E, quyết định 2026-07-14).
//
// Điều kiện tiên quyết: document users/<admin uid> đã được tạo TAY qua
// Firestore Console trước (bootstrap — xem giải thích trong hội thoại: rule
// `allow create: if isAdmin()` của collection users tự deadlock nếu không
// còn document admin nào để isAdmin() chứng minh).
//
// Logic ca/ngày làm việc PORT nguyên văn từ:
//   attendance_mobile/lib/core/utils/rotation_calculator.dart (getCurrentShift)
//   attendance_mobile/lib/core/utils/work_schedule_helper.dart (getDayType)
// KHÔNG hardcode rotationStartDate/rotationDays — luôn đọc từ
// company_settings/main hiện có (Single Source of Truth, xem TD-03).
//
// Cách chạy (từ thư mục tools/firestore_backup):
//   BACKUP_ADMIN_EMAIL=... BACKUP_ADMIN_PASSWORD=... \
//   SEED_PW_EMP001=... SEED_PW_EMP002=... SEED_PW_EMP003=... SEED_PW_EMP004=... \
//   dart run bin/reseed_july.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'package:firestore_backup/firebase_client.dart';
import 'package:firestore_backup/firestore_value_converter.dart';

const _adminUid = 'UqyJA2oAr6VzjrOeAUkZRJXRAgh2';
const _adminEmail = 'admin@gmail.com';

class _Employee {
  final String uid;
  final String email;
  final String employeeCode;
  final String name;
  final String shiftGroup;
  final String departmentId;
  final String passwordEnvVar;

  const _Employee({
    required this.uid,
    required this.email,
    required this.employeeCode,
    required this.name,
    required this.shiftGroup,
    required this.departmentId,
    required this.passwordEnvVar,
  });
}

const _employees = [
  _Employee(
    uid: '4Znnqs0bxiXbFeYimTQ5znDL5dG3',
    email: 'shiroyasha284@gmail.com',
    employeeCode: 'EMP001',
    name: 'Trần Văn Ab',
    shiftGroup: 'A',
    departmentId: 'dept_ga',
    passwordEnvVar: 'SEED_PW_EMP001',
  ),
  _Employee(
    uid: 'Nuav1I87ZOg1M0AysReIoaeUv2C2',
    email: 'dntienktpm2211046@student.ctuet.edu.vn',
    employeeCode: 'EMP002',
    name: 'Lê Thị B',
    shiftGroup: 'B',
    departmentId: 'dept_dx',
    passwordEnvVar: 'SEED_PW_EMP002',
  ),
  _Employee(
    uid: '7VtAl9r6rcRgBGLXcVTtUcNn05l2',
    email: 'danhnhattien284@gmail.com',
    employeeCode: 'EMP003',
    name: 'Danh Nhật Tiến',
    shiftGroup: 'B',
    departmentId: 'dept_pe',
    passwordEnvVar: 'SEED_PW_EMP003',
  ),
  _Employee(
    uid: 'CDjUg3doU1XNqolc4peROxLnJXv2',
    email: 'tadinhtri2004@gmail.com',
    employeeCode: 'EMP004',
    name: 'Tạ Đình Trí',
    shiftGroup: 'A',
    departmentId: 'dept_te',
    passwordEnvVar: 'SEED_PW_EMP004',
  ),
];

const _departments = {
  'dept_acc': 'Phòng Kế toán (ACC Dept)',
  'dept_dx': 'Phòng Chuyển đổi số (DX Dept)',
  'dept_fac': 'Phòng Cơ sở vật chất (FAC Dept)',
  'dept_ga': 'Phòng Hành chính – Nhân sự (GA Dept)',
  'dept_ia': 'Bộ phận Kiểm toán nội bộ (Internal Audit)',
  'dept_pd': 'Phòng PD (PD Dept)',
  'dept_pe': 'Phòng Kỹ thuật sản xuất (PE Dept)',
  'dept_pmc': 'Phòng PMC (PMC Dept)',
  'dept_pur1': 'Phòng Mua hàng 1 (PUR Dept 1)',
  'dept_pur2': 'Phòng Mua hàng 2 (PUR Dept 2)',
  'dept_qa': 'Phòng Đảm bảo chất lượng (QA Dept)',
  'dept_sales': 'Phòng Kinh doanh (Sales Dept)',
  'dept_te': 'Phòng Kỹ thuật (TE Dept)',
};

const _targetMonthDays = 14; // 1-14/7/2026 (tới hôm nay, quyết định 2026-07-14)

Future<void> main() async {
  stdout.writeln('=== Reseed tháng 7/2026 (sau khi đã xoá sạch) ===');
  stdout.writeln();

  // ---- Phase A: đăng nhập admin, tạo departments + hồ sơ 4 nhân viên ----
  final adminPassword = readCredential('BACKUP_ADMIN_PASSWORD', 'Admin password');
  stdout.writeln('Đăng nhập admin...');
  final adminToken = await signIn(_adminEmail, adminPassword);
  stdout.writeln('OK.');
  stdout.writeln();

  stdout.writeln('Tạo 13 phòng ban...');
  for (final entry in _departments.entries) {
    await _putDoc(
      token: adminToken,
      docPath: 'departments/${entry.key}',
      fields: {
        'name': entry.value,
        'managerUid': _adminUid,
        'createdAt': DateTime.now(),
      },
    );
  }
  stdout.writeln('OK.');
  stdout.writeln();

  stdout.writeln('Tạo hồ sơ 4 nhân viên...');
  for (final emp in _employees) {
    await _putDoc(
      token: adminToken,
      docPath: 'users/${emp.uid}',
      fields: {
        'employeeCode': emp.employeeCode,
        'name': emp.name,
        'email': emp.email,
        'role': 'employee',
        'shiftGroup': emp.shiftGroup,
        'departmentId': emp.departmentId,
        'phone': '0901234567',
        'avatarUrl': '',
        'isActive': true,
        'createdAt': DateTime.now(),
      },
    );
    stdout.writeln('  -> ${emp.employeeCode} (${emp.name})');
  }
  stdout.writeln();

  // ---- Đọc company_settings làm Single Source of Truth cho rotation ----
  final settingsResponse = await http.get(
    Uri.parse('$firestoreBaseUrl/company_settings/main'),
    headers: {'Authorization': 'Bearer $adminToken'},
  );
  if (settingsResponse.statusCode != 200) {
    stderr.writeln('Đọc company_settings/main thất bại: ${settingsResponse.body}');
    exit(1);
  }
  final settingsFields =
      (jsonDecode(settingsResponse.body) as Map<String, dynamic>)['fields']
          as Map<String, dynamic>;
  final settingsData = convertFirestoreFields(settingsFields);
  final rotationStartDate = DateTime.parse(settingsData['rotationStartDate'] as String).toLocal();
  final rotationDays = settingsData['rotationDays'] as int;
  final latitude = (settingsData['latitude'] as num).toDouble();
  final longitude = (settingsData['longitude'] as num).toDouble();

  stdout.writeln('company_settings: rotationStartDate=$rotationStartDate, rotationDays=$rotationDays');
  stdout.writeln();

  // ---- Phase B: từng nhân viên tự đăng nhập, tự tạo attendance của mình ----
  // Random() không seed cố định -> mỗi lần chạy script cho kết quả khác nhau,
  // và mỗi nhân viên/mỗi ngày cũng không lặp lại cùng 1 khuôn mẫu như trước
  // (trước đây dùng Random(day) — cùng ngày thì mọi nhân viên ra y hệt nhau).
  final random = Random();

  for (final emp in _employees) {
    final password = readCredential(emp.passwordEnvVar, '${emp.employeeCode} password');
    stdout.writeln('Đăng nhập ${emp.employeeCode} (${emp.email})...');
    final token = await signIn(emp.email, password);
    stdout.writeln('OK, đang tạo attendance tháng 7...');

    var created = 0;
    for (int day = 1; day <= _targetMonthDays; day++) {
      final date = DateTime(2026, 7, day);
      final dayType = _getDayType(date, rotationStartDate);
      if (dayType == 'off') continue;

      final shift = _getCurrentShift(
        rotationStartDate: rotationStartDate,
        rotationDays: rotationDays,
        shiftGroup: emp.shiftGroup,
        date: date,
      );
      final isDay = shift == 'day';
      final startHour = isDay ? 8 : 20;
      final endHour = isDay ? 20 : 8;
      final isToday = day == _targetMonthDays; // 14/7 — bản ghi "đang làm việc"

      // Random có trọng số thay vì lặp cứng theo day % n — các khoảng roll
      // không chồng nhau: [0,45) đúng giờ, [45,65) muộn, [65,80) về sớm,
      // [80,90) vừa muộn vừa về sớm, [90,100) vắng.
      final roll = random.nextInt(100);
      final isAbsent = roll >= 90;
      if (isAbsent && !isToday) continue;

      final isLate = (roll >= 45 && roll < 65) || (roll >= 80 && roll < 90);
      final wantsEarlyLeave = roll >= 65 && roll < 90;

      final checkIn = isLate
          ? DateTime(date.year, date.month, date.day, startHour, 15 + random.nextInt(20))
          : DateTime(date.year, date.month, date.day, startHour - 1, 45 + random.nextInt(14));

      DateTime? checkOut;
      bool isEarlyLeave = false;
      String status;

      if (isToday) {
        status = isLate ? 'late' : 'on_time';
      } else {
        final checkoutDate = !isDay ? date.add(const Duration(days: 1)) : date;
        isEarlyLeave = wantsEarlyLeave;
        if (isEarlyLeave) {
          checkOut = DateTime(checkoutDate.year, checkoutDate.month, checkoutDate.day, endHour - 1, 20 + random.nextInt(30));
        } else {
          checkOut = DateTime(checkoutDate.year, checkoutDate.month, checkoutDate.day, endHour, random.nextInt(10));
        }
        status = isLate ? 'late' : (isEarlyLeave ? 'early_leave' : 'completed');
      }

      final docId =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}_${emp.uid}';

      await _putDoc(
        token: token,
        docPath: 'attendance/$docId',
        fields: {
          'uid': emp.uid,
          'employeeCode': emp.employeeCode,
          'shift': shift,
          'attendanceDate': date,
          'checkIn': checkIn,
          'checkOut': checkOut,
          'latitude': latitude + (random.nextDouble() - 0.5) * 0.0006,
          'longitude': longitude + (random.nextDouble() - 0.5) * 0.0006,
          'distance': 10.0 + random.nextDouble() * 30,
          'workHours': checkOut != null ? checkOut.difference(checkIn).inMinutes / 60.0 : 0.0,
          'isLate': isLate,
          'isEarlyLeave': isEarlyLeave,
          'status': status,
          'createdAt': checkIn,
        },
      );
      created++;
    }
    stdout.writeln('  -> $created bản ghi attendance cho ${emp.employeeCode}.');
    stdout.writeln();
  }

  stdout.writeln('Hoàn tất.');
}

// ---------------------------------------------------------------------------
// Logic ca/ngày làm việc — port nguyên văn từ rotation_calculator.dart và
// work_schedule_helper.dart (mobile), giữ đúng công thức, không đổi.
// ---------------------------------------------------------------------------

String _getCurrentShift({
  required DateTime rotationStartDate,
  required int rotationDays,
  required String shiftGroup,
  required DateTime date,
}) {
  final normalizedStart = DateTime(rotationStartDate.year, rotationStartDate.month, rotationStartDate.day);
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final daysPassed = normalizedDate.difference(normalizedStart).inDays;
  final rotationIndex = (daysPassed / rotationDays).floor();
  final isFlipped = rotationIndex % 2 != 0;
  if (shiftGroup == 'B') {
    return isFlipped ? 'night' : 'day';
  } else {
    return isFlipped ? 'day' : 'night';
  }
}

bool _isOddWeek(DateTime date, DateTime rotationStartDate) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final normalizedStart = DateTime(rotationStartDate.year, rotationStartDate.month, rotationStartDate.day);
  final daysPassed = normalizedDate.difference(normalizedStart).inDays;
  final totalWeeks = daysPassed ~/ 7;
  return totalWeeks % 2 == 0;
}

String _getDayType(DateTime date, DateTime rotationStartDate) {
  final weekday = date.weekday;
  final oddWeek = _isOddWeek(date, rotationStartDate);

  if (oddWeek) {
    if (weekday >= 1 && weekday <= 6) return 'work';
    if (weekday == 7) return 'overtime';
  } else {
    if (weekday >= 1 && weekday <= 5) return 'work';
    if (weekday == 6) return 'overtime';
    if (weekday == 7) return 'off';
  }
  return 'off';
}

// ---------------------------------------------------------------------------
// Ghi document (create-or-replace toàn bộ field được liệt kê — dùng PATCH
// không kèm updateMask, đúng ngữ nghĩa "set" của Firestore REST API).
// ---------------------------------------------------------------------------

Future<void> _putDoc({
  required String token,
  required String docPath,
  required Map<String, dynamic> fields,
}) async {
  final body = {
    'fields': fields.map((key, value) => MapEntry(key, _toValue(value))),
  };

  final response = await http.patch(
    Uri.parse('$firestoreBaseUrl/$docPath'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode != 200) {
    stderr.writeln('Ghi "$docPath" thất bại (${response.statusCode}): ${response.body}');
    exit(1);
  }
}

Map<String, dynamic> _toValue(dynamic value) {
  if (value == null) return {'nullValue': null};
  if (value is DateTime) {
    return {'timestampValue': value.toUtc().toIso8601String()};
  }
  return toFirestoreValue(value);
}
