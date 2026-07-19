import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/attendance_repository.dart';
import '../domain/attendance_model.dart';

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository());

/// Tham số là ngày admin đã chọn lọc (null = chưa chọn, mặc định tháng hiện
/// tại) -- TD-06, tránh tải toàn bộ lịch sử chấm công không giới hạn.
final attendanceStreamProvider =
    StreamProvider.family<List<AttendanceModel>, DateTime?>((ref, selectedDate) {
  final DateTime start;
  final DateTime end;

  if (selectedDate != null) {
    start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    end = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
  } else {
    final now = DateTime.now();
    start = DateTime(now.year, now.month, 1);
    end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  return ref.watch(attendanceRepositoryProvider).getAttendanceLogs(start: start, end: end);
});
