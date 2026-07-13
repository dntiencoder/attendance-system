import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Dùng chung giữa backup_firestore.dart và import_firestore.dart.

const projectId = 'attendance-management-sy-34105';

// Web API Key của project (không phải secret — đây là giá trị public dùng
// trong client app, lấy từ attendance_admin/lib/firebase_options.dart).
// An toàn của hệ thống nằm ở firestore.rules, không nằm ở việc giấu key này.
const webApiKey = 'AIzaSyDeLZttkVQkAreob5OFTvqlQEr3UflwO9E';

const _authEndpoint =
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword';

String get firestoreBaseUrl =>
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

class PermissionDeniedException implements Exception {}

/// Đọc credential từ biến môi trường [envVar], nếu không có thì hỏi qua stdin
/// với [prompt]. Không lưu lại giá trị này ở đâu ngoài bộ nhớ tiến trình.
String readCredential(String envVar, String prompt) {
  final fromEnv = Platform.environment[envVar];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

  stdout.write('$prompt: ');
  final value = stdin.readLineSync();
  if (value == null || value.isEmpty) {
    stderr.writeln('Thiếu $prompt. Dừng chương trình.');
    exit(1);
  }
  return value;
}

/// Đăng nhập bằng Firebase Auth REST API, trả về idToken dùng cho các lời
/// gọi Firestore REST API tiếp theo.
Future<String> signIn(String email, String password) async {
  final response = await http.post(
    Uri.parse('$_authEndpoint?key=$webApiKey'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
      'returnSecureToken': true,
    }),
  );

  if (response.statusCode != 200) {
    stderr.writeln('Đăng nhập thất bại: ${response.body}');
    exit(1);
  }

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  return body['idToken'] as String;
}

/// Tìm thư mục gốc của repo (chứa attendance_mobile/, attendance_admin/,
/// tools/) dựa trên vị trí của script đang chạy, không phụ thuộc thư mục
/// hiện hành lúc gọi `dart run`.
Directory findRepoRoot() {
  final scriptDir = File(Platform.script.toFilePath()).parent; // .../tools/firestore_backup/bin
  return scriptDir.parent.parent; // bin -> firestore_backup -> tools -> repo root
}
