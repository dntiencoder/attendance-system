import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/attendance_repository.dart';
import '../domain/attendance_model.dart';

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository());

/// Tham số là khoảng ngày admin đã chọn lọc (null = chưa chọn, mặc định
/// tháng hiện tại) -- TD-06, tránh tải toàn bộ lịch sử chấm công không giới
/// hạn. Đổi từ `DateTime?` (1 ngày) sang `DateTimeRange?` để hỗ trợ lọc
/// khoảng ngày từ-đến.
final attendanceStreamProvider =
    StreamProvider.family<List<AttendanceModel>, DateTimeRange?>((ref, selectedRange) {
  final DateTime start;
  final DateTime end;

  if (selectedRange != null) {
    start = DateTime(selectedRange.start.year, selectedRange.start.month, selectedRange.start.day);
    end = DateTime(selectedRange.end.year, selectedRange.end.month, selectedRange.end.day, 23, 59, 59);
  } else {
    final now = DateTime.now();
    start = DateTime(now.year, now.month, 1);
    end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  return ref.watch(attendanceRepositoryProvider).getAttendanceLogs(start: start, end: end);
});
