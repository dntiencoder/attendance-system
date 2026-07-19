import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/attendance_model.dart';

class AttendanceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// [start]/[end] giới hạn khoảng ngày cần tải (TD-06) -- tránh stream toàn
  /// bộ collection về không giới hạn khi dữ liệu tích luỹ lâu dài.
  Stream<List<AttendanceModel>> getAttendanceLogs({
    required DateTime start,
    required DateTime end,
  }) {
    return _db.collection('attendance')
        .where('attendanceDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('attendanceDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('attendanceDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    });
  }
}
