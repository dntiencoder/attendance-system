// Script one-off cho Sprint 0 (D.1 — Demo báo cáo tiến độ), xem
// docs/project/PROJECT_MASTER_PLAN.md mục D.1 và docs/demo/01_DEMO_DATA.md
// mục 2 + 7.
//
// Ghi đúng 2 thay đổi dữ liệu (KHÔNG đụng code app, KHÔNG đổi schema/rules):
//   1. company_settings/main.radius: 9999999999 -> 500 (mét)
//   2. users/<admin uid>.departmentId: "dep001" (không tồn tại) -> "dept_ga"
//
// Cả 2 field đều nằm trong nhánh `allow write/update: if isAdmin()` của
// firestore.rules, nên đăng nhập bằng tài khoản admin là đủ quyền — không
// cần Service Account. Không dùng cho leave_requests vì rule create của
// collection đó yêu cầu request.auth.uid == uid trong document (xem
// docs/project/03_PROGRESS.md), đăng nhập admin không tạo hộ được.
//
// Cách chạy (từ thư mục tools/firestore_backup, sau khi `dart pub get`):
//   dart run bin/seed_sprint0.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:firestore_backup/firebase_client.dart';
import 'package:firestore_backup/firestore_value_converter.dart';

const _adminUid = 'UqyJA2oAr6VzjrOeAUkZRJXRAgh2';
const _newRadius = 500.0;
const _newDepartmentId = 'dept_ga';

Future<void> main() async {
  stdout.writeln('=== Sprint 0 seed tool (radius + admin departmentId) ===');
  stdout.writeln();

  final email = readCredential('BACKUP_ADMIN_EMAIL', 'Admin email');
  final password = readCredential('BACKUP_ADMIN_PASSWORD', 'Admin password');

  stdout.writeln('Đang đăng nhập...');
  final idToken = await signIn(email, password);
  stdout.writeln('Đăng nhập thành công.');
  stdout.writeln();

  await _patchField(
    idToken: idToken,
    docPath: 'company_settings/main',
    fieldName: 'radius',
    newValue: _newRadius,
  );

  await _patchField(
    idToken: idToken,
    docPath: 'users/$_adminUid',
    fieldName: 'departmentId',
    newValue: _newDepartmentId,
  );

  stdout.writeln();
  stdout.writeln('Hoàn tất.');
}

Future<void> _patchField({
  required String idToken,
  required String docPath,
  required String fieldName,
  required dynamic newValue,
}) async {
  final uri = Uri.parse('$firestoreBaseUrl/$docPath').replace(
    queryParameters: {'updateMask.fieldPaths': fieldName},
  );

  final getResponse = await http.get(
    Uri.parse('$firestoreBaseUrl/$docPath'),
    headers: {'Authorization': 'Bearer $idToken'},
  );
  if (getResponse.statusCode != 200) {
    stderr.writeln(
      'Đọc "$docPath" thất bại (${getResponse.statusCode}): ${getResponse.body}',
    );
    exit(1);
  }
  final beforeFields =
      (jsonDecode(getResponse.body) as Map<String, dynamic>)['fields']
          as Map<String, dynamic>? ??
      const {};
  final beforeValue = beforeFields.containsKey(fieldName)
      ? convertFirestoreValue(beforeFields[fieldName] as Map<String, dynamic>)
      : null;

  final response = await http.patch(
    uri,
    headers: {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'fields': {fieldName: toFirestoreValue(newValue, fieldName: fieldName)},
    }),
  );

  if (response.statusCode != 200) {
    stderr.writeln(
      'Ghi "$docPath".$fieldName thất bại (${response.statusCode}): ${response.body}',
    );
    exit(1);
  }

  stdout.writeln('$docPath.$fieldName: $beforeValue -> $newValue');
}
