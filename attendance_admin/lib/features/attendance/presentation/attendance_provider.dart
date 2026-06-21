import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/attendance_repository.dart';
import '../domain/attendance_model.dart';

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository());

final attendanceStreamProvider = StreamProvider<List<AttendanceModel>>((ref) {
  return ref.watch(attendanceRepositoryProvider).getAttendanceLogs();
});
