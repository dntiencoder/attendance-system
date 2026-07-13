// Công cụ backup Firestore cho project attendance-system, phục vụ demo.
//
// KHÔNG dùng Firebase Export / gcloud export (cần Cloud Storage + Billing).
// Thay vào đó, script gọi trực tiếp Firestore REST API + Firebase Auth REST
// API, đăng nhập bằng chính tài khoản admin đã có trong hệ thống (email/mật
// khẩu nhập lúc chạy, KHÔNG lưu lại ở đâu cả) — quyền đọc bị giới hạn đúng
// theo firestore.rules hiện tại, không bỏ qua rules như Service Account.
//
// Cách chạy (từ thư mục tools/firestore_backup, sau khi `dart pub get`):
//   dart run bin/backup_firestore.dart
//
// Xem chi tiết cách hoạt động và giới hạn tại docs/developer/FIRESTORE_BACKUP.md.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:firestore_backup/firestore_value_converter.dart';
import 'package:firestore_backup/firebase_client.dart';

/// Regex tìm `.collection('tên')` hoặc `.collection("tên")` trong source code.
final _collectionCallPattern =
    RegExp('''\\.collection\\(\\s*['"]([a-zA-Z0-9_]+)['"]\\s*\\)''');

const _maxSubcollectionDepth = 5;

Future<void> main(List<String> args) async {
  final repoRoot = findRepoRoot();

  stdout.writeln('=== Firestore Backup Tool (attendance-system) ===');
  stdout.writeln('Repo root: ${repoRoot.path}');
  stdout.writeln();

  // 1. Quét source code tìm toàn bộ collection đang được dùng.
  final scannedCollections = await _scanCollectionNames(repoRoot);
  stdout.writeln('Tìm thấy ${scannedCollections.length} collection trong source code:');
  for (final name in scannedCollections) {
    stdout.writeln('  - $name');
  }
  stdout.writeln();

  // 2. Đăng nhập bằng tài khoản admin (không lưu lại thông tin đăng nhập).
  final email = readCredential('BACKUP_ADMIN_EMAIL', 'Admin email');
  final password = readCredential('BACKUP_ADMIN_PASSWORD', 'Admin password');

  stdout.writeln('Đang đăng nhập...');
  final idToken = await signIn(email, password);
  stdout.writeln('Đăng nhập thành công.');
  stdout.writeln();

  // 3. Đối chiếu với danh sách collection thật đang tồn tại (nếu đọc được).
  final liveRootCollections = await _listRootCollectionIds(idToken);
  final onlyInCode = scannedCollections.difference(liveRootCollections);
  final onlyLive = liveRootCollections.difference(scannedCollections);

  // 4. Đọc dữ liệu từng collection tìm được trong code (nguồn chính thức
  // theo yêu cầu), cộng thêm bất kỳ collection nào chỉ tồn tại thật (onlyLive)
  // để không bỏ sót dữ liệu thật.
  final collectionsToExport = {...scannedCollections, ...onlyLive}.toList()..sort();

  final collections = <String, Map<String, dynamic>>{};
  final permissionDenied = <String>[];

  for (final collectionId in collectionsToExport) {
    stdout.writeln('Đang đọc collection "$collectionId"...');
    try {
      await _exportCollection(
        collectionPath: collectionId,
        idToken: idToken,
        collections: collections,
        depth: 0,
      );
    } on PermissionDeniedException {
      stdout.writeln('  -> Bị từ chối quyền đọc (permission-denied). Bỏ qua.');
      permissionDenied.add(collectionId);
      collections[collectionId] = {};
    }
  }

  // 5. Ghi backup_firestore.json
  final backup = {
    'project': projectId,
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'collections': collections,
  };

  final backupFile = File('${repoRoot.path}/backup_firestore.json');
  await backupFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(backup),
  );
  stdout.writeln();
  stdout.writeln('Đã ghi ${backupFile.path}');

  // 6. Ghi BACKUP_SUMMARY.md
  await _writeSummary(
    repoRoot: repoRoot,
    collections: collections,
    scannedCollections: scannedCollections,
    onlyInCode: onlyInCode,
    onlyLive: onlyLive,
    permissionDenied: permissionDenied,
  );

  stdout.writeln('Hoàn tất.');
}

// ---------------------------------------------------------------------------
// Quét source code
// ---------------------------------------------------------------------------

Future<Set<String>> _scanCollectionNames(Directory repoRoot) async {
  final names = <String>{};

  final searchDirs = [
    Directory('${repoRoot.path}/attendance_mobile/lib'),
    Directory('${repoRoot.path}/attendance_admin/lib'),
  ];

  for (final dir in searchDirs) {
    if (!dir.existsSync()) continue;

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final content = await entity.readAsString();
      for (final match in _collectionCallPattern.allMatches(content)) {
        final name = match.group(1);
        if (name != null) names.add(name);
      }
    }
  }

  return names;
}

// ---------------------------------------------------------------------------
// Đọc dữ liệu Firestore
// ---------------------------------------------------------------------------

Future<Set<String>> _listRootCollectionIds(String idToken) async {
  try {
    return await _listCollectionIds('$firestoreBaseUrl:listCollectionIds', idToken);
  } catch (_) {
    // Nếu vì lý do gì đó không gọi được (vd rules chặn), không chặn toàn bộ
    // tiến trình backup — chỉ bỏ qua bước đối chiếu.
    return {};
  }
}

Future<Set<String>> _listCollectionIds(String url, String idToken) async {
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'pageSize': 300}),
  );

  if (response.statusCode == 403) throw PermissionDeniedException();
  if (response.statusCode != 200) {
    throw Exception('listCollectionIds thất bại (${response.statusCode}): ${response.body}');
  }

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  final ids = body['collectionIds'] as List<dynamic>? ?? const [];
  return ids.map((e) => e as String).toSet();
}

/// Đọc toàn bộ document của [collectionPath] (đường dẫn tương đối, có thể là
/// collection gốc "attendance" hoặc subcollection "users/uid/logs"), ghi kết
/// quả vào [collections], rồi đệ quy phát hiện + đọc tiếp subcollection của
/// từng document.
Future<void> _exportCollection({
  required String collectionPath,
  required String idToken,
  required Map<String, Map<String, dynamic>> collections,
  required int depth,
}) async {
  if (depth > _maxSubcollectionDepth) {
    stdout.writeln('  -> Đạt độ sâu subcollection tối đa, dừng đệ quy tại "$collectionPath".');
    return;
  }

  final documents = <String, dynamic>{};
  collections[collectionPath] = documents;

  String? pageToken;
  final docPaths = <String>[];

  do {
    final uri = Uri.parse('$firestoreBaseUrl/$collectionPath').replace(
      queryParameters: {
        'pageSize': '300',
        if (pageToken != null) 'pageToken': pageToken,
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 403) throw PermissionDeniedException();
    if (response.statusCode == 404) break; // Collection không tồn tại thật.
    if (response.statusCode != 200) {
      throw Exception('Đọc "$collectionPath" thất bại (${response.statusCode}): ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = body['documents'] as List<dynamic>? ?? const [];

    for (final rawDoc in docs) {
      final doc = rawDoc as Map<String, dynamic>;
      final fullName = doc['name'] as String;
      final docId = fullName.substring(fullName.lastIndexOf('/') + 1);
      final fields = doc['fields'] as Map<String, dynamic>? ?? const {};

      documents[docId] = convertFirestoreFields(fields);
      docPaths.add(relativeDocumentPath(fullName));
    }

    pageToken = body['nextPageToken'] as String?;
  } while (pageToken != null);

  stdout.writeln('  -> ${documents.length} document.');

  // Phát hiện + đọc subcollection cho từng document.
  for (final docPath in docPaths) {
    Set<String> subIds;
    try {
      subIds = await _listCollectionIds(
        '$firestoreBaseUrl/$docPath:listCollectionIds',
        idToken,
      );
    } on PermissionDeniedException {
      continue;
    }

    for (final subId in subIds) {
      final subPath = '$docPath/$subId';
      stdout.writeln('  Phát hiện subcollection "$subPath"');
      await _exportCollection(
        collectionPath: subPath,
        idToken: idToken,
        collections: collections,
        depth: depth + 1,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// BACKUP_SUMMARY.md
// ---------------------------------------------------------------------------

Future<void> _writeSummary({
  required Directory repoRoot,
  required Map<String, Map<String, dynamic>> collections,
  required Set<String> scannedCollections,
  required Set<String> onlyInCode,
  required Set<String> onlyLive,
  required List<String> permissionDenied,
}) async {
  final topLevel = collections.keys.where((k) => !k.contains('/')).toList()..sort();
  final subcollections = collections.keys.where((k) => k.contains('/')).toList()..sort();

  final docCounts = {
    for (final entry in collections.entries) entry.key: entry.value.length,
  };
  final totalDocs = docCounts.values.fold<int>(0, (a, b) => a + b);
  final emptyCollections = collections.entries.where((e) => e.value.isEmpty).map((e) => e.key).toList()..sort();

  String busiest = '(không có)';
  var busiestCount = -1;
  docCounts.forEach((name, count) {
    if (count > busiestCount) {
      busiest = name;
      busiestCount = count;
    }
  });

  final buffer = StringBuffer()
    ..writeln('# Backup Summary')
    ..writeln()
    ..writeln('Tự động sinh bởi `tools/firestore_backup`. Không sửa tay file này — chạy lại tool để cập nhật.')
    ..writeln()
    ..writeln('- **Thời điểm backup:** ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('- **Tổng số collection gốc:** ${topLevel.length}')
    ..writeln('- **Tổng số subcollection:** ${subcollections.length}')
    ..writeln('- **Tổng số document (gồm cả subcollection):** $totalDocs')
    ..writeln('- **Collection nhiều document nhất:** `$busiest` ($busiestCount document)')
    ..writeln()
    ..writeln('## Chi tiết theo collection gốc')
    ..writeln()
    ..writeln('| Collection | Số document |')
    ..writeln('|---|---|');

  for (final name in topLevel) {
    buffer.writeln('| `$name` | ${docCounts[name]} |');
  }

  if (subcollections.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Subcollection phát hiện được')
      ..writeln()
      ..writeln('| Đường dẫn | Số document |')
      ..writeln('|---|---|');
    for (final name in subcollections) {
      buffer.writeln('| `$name` | ${docCounts[name]} |');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Collection rỗng')
    ..writeln();
  if (emptyCollections.isEmpty) {
    buffer.writeln('Không có collection nào rỗng.');
  } else {
    for (final name in emptyCollections) {
      buffer.writeln('- `$name`');
    }
  }

  if (onlyInCode.isNotEmpty || onlyLive.isNotEmpty || permissionDenied.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Cảnh báo đối chiếu')
      ..writeln();
    if (onlyInCode.isNotEmpty) {
      buffer.writeln('- Có trong code nhưng không thấy tồn tại thật trong Firestore: ${onlyInCode.map((e) => '`$e`').join(', ')}');
    }
    if (onlyLive.isNotEmpty) {
      buffer.writeln('- Tồn tại thật trong Firestore nhưng không tìm thấy trong code (đã backup bổ sung): ${onlyLive.map((e) => '`$e`').join(', ')}');
    }
    if (permissionDenied.isNotEmpty) {
      buffer.writeln('- Bị từ chối quyền đọc (permission-denied), backup rỗng cho collection này: ${permissionDenied.map((e) => '`$e`').join(', ')}');
    }
  }

  final summaryFile = File('${repoRoot.path}/BACKUP_SUMMARY.md');
  await summaryFile.writeAsString(buffer.toString());
  stdout.writeln('Đã ghi ${summaryFile.path}');
}
