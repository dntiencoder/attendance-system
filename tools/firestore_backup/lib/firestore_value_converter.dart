/// Chuyển đổi giá trị field ở định dạng Firestore REST API ("Value" object)
/// thành giá trị JSON thuần, có thể ghi thẳng ra file bằng `jsonEncode`.
///
/// Tham chiếu định dạng gốc: mỗi field trả về từ Firestore REST API được bọc
/// trong 1 trong các key: stringValue / integerValue / doubleValue /
/// booleanValue / nullValue / timestampValue / geoPointValue / referenceValue
/// / bytesValue / arrayValue / mapValue.
dynamic convertFirestoreValue(Map<String, dynamic> value) {
  if (value.containsKey('stringValue')) return value['stringValue'];

  if (value.containsKey('integerValue')) {
    return int.parse(value['integerValue'] as String);
  }

  if (value.containsKey('doubleValue')) {
    return (value['doubleValue'] as num).toDouble();
  }

  if (value.containsKey('booleanValue')) return value['booleanValue'];

  if (value.containsKey('nullValue')) return null;

  // Firestore REST API đã trả timestampValue dưới dạng chuỗi ISO 8601 sẵn.
  if (value.containsKey('timestampValue')) return value['timestampValue'];

  if (value.containsKey('geoPointValue')) {
    final geo = value['geoPointValue'] as Map<String, dynamic>;
    return {
      'latitude': geo['latitude'],
      'longitude': geo['longitude'],
    };
  }

  if (value.containsKey('referenceValue')) {
    return relativeDocumentPath(value['referenceValue'] as String);
  }

  // Firestore REST API đã trả bytesValue dưới dạng chuỗi base64 sẵn.
  if (value.containsKey('bytesValue')) return value['bytesValue'];

  if (value.containsKey('arrayValue')) {
    final values =
        (value['arrayValue'] as Map<String, dynamic>)['values'] as List<dynamic>? ??
            const [];
    return values
        .map((v) => convertFirestoreValue(v as Map<String, dynamic>))
        .toList();
  }

  if (value.containsKey('mapValue')) {
    final fields = (value['mapValue'] as Map<String, dynamic>)['fields']
            as Map<String, dynamic>? ??
        const {};
    return convertFirestoreFields(fields);
  }

  // Không rơi vào trường hợp nào đã biết -> giữ nguyên để không âm thầm mất dữ liệu.
  return value;
}

/// Chuyển đổi toàn bộ map "fields" của 1 document Firestore REST API thành
/// `Map<String, dynamic>` JSON thuần.
Map<String, dynamic> convertFirestoreFields(Map<String, dynamic> fields) {
  return fields.map(
    (key, value) =>
        MapEntry(key, convertFirestoreValue(value as Map<String, dynamic>)),
  );
}

/// Rút gọn "projects/x/databases/(default)/documents/users/abc" thành
/// "users/abc" — dễ đọc hơn trong file backup, vẫn đủ để xác định document.
String relativeDocumentPath(String fullPath) {
  const marker = '/documents/';
  final index = fullPath.indexOf(marker);
  if (index == -1) return fullPath;
  return fullPath.substring(index + marker.length);
}

// ---------------------------------------------------------------------------
// Chiều ngược: JSON thuần (đọc từ backup_firestore.json) -> Firestore REST
// "Value" object, dùng khi import/khôi phục dữ liệu.
//
// GIỚI HẠN QUAN TRỌNG: khi backup, Timestamp và chuỗi thường đều bị lưu
// thành cùng kiểu String trong JSON — không còn cách nào phân biệt tuyệt đối
// giá trị nào từng là Timestamp chỉ dựa vào bản thân giá trị đó. Để khôi phục
// đúng, ta dựa vào TÊN FIELD đã biết trước trong schema hiện tại của dự án.
// Nếu sau này thêm field Timestamp mới với tên khác [timestampFieldNames],
// cần bổ sung tên đó vào danh sách dưới đây, nếu không field đó sẽ bị khôi
// phục thành chuỗi thường thay vì Timestamp.
// ---------------------------------------------------------------------------

/// Danh sách tên field được biết là kiểu Timestamp trong schema hiện tại của
/// dự án (users, attendance, company_settings, leave_requests, notifications).
const Set<String> timestampFieldNames = {
  'createdAt',
  'updatedAt',
  'checkIn',
  'checkOut',
  'checkOutTime',
  'attendanceDate',
  'rotationStartDate',
  'seededAt',
};

final _iso8601Pattern =
    RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}');

bool _looksLikeIso8601(String value) => _iso8601Pattern.hasMatch(value);

/// Chuyển 1 giá trị JSON thuần thành Firestore REST "Value" object.
/// [fieldName] (nếu có) được dùng để quyết định 1 chuỗi có nên khôi phục
/// thành Timestamp hay không — xem giải thích ở đầu phần này.
Map<String, dynamic> toFirestoreValue(dynamic value, {String? fieldName}) {
  if (value == null) return {'nullValue': null};

  if (value is bool) return {'booleanValue': value};

  if (value is int) return {'integerValue': value.toString()};

  if (value is double) return {'doubleValue': value};

  if (value is String) {
    if (fieldName != null &&
        timestampFieldNames.contains(fieldName) &&
        _looksLikeIso8601(value)) {
      return {'timestampValue': value};
    }
    return {'stringValue': value};
  }

  if (value is List) {
    return {
      'arrayValue': {
        'values': value.map((v) => toFirestoreValue(v)).toList(),
      },
    };
  }

  if (value is Map) {
    final map = Map<String, dynamic>.from(value);

    // Heuristic: map đúng 2 field latitude/longitude -> coi là GeoPoint.
    // Dự án hiện không dùng map nào khác trùng đúng 2 key này.
    if (map.length == 2 &&
        map.containsKey('latitude') &&
        map.containsKey('longitude')) {
      return {
        'geoPointValue': {
          'latitude': map['latitude'],
          'longitude': map['longitude'],
        },
      };
    }

    return {'mapValue': {'fields': toFirestoreFields(map)}};
  }

  throw ArgumentError(
    'Không hỗ trợ convert ngược giá trị "$value" (field: $fieldName, kiểu: ${value.runtimeType}).',
  );
}

/// Chuyển toàn bộ 1 document JSON thuần (Map<String, dynamic>) thành map
/// "fields" theo đúng định dạng Firestore REST API để ghi lên Firestore.
Map<String, dynamic> toFirestoreFields(Map<String, dynamic> document) {
  return document.map(
    (key, value) => MapEntry(key, toFirestoreValue(value, fieldName: key)),
  );
}
