import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/attendance_repository.dart';
import '../domain/attendance_model.dart';

// Provider cho repository
final attendanceRepositoryProvider = Provider<AttendanceRepository>(
      (ref) => AttendanceRepository(),
);

// ===== STATE =====
class AttendanceState {
  final AttendanceModel? todayAttendance;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  AttendanceState({
    this.todayAttendance,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  AttendanceState copyWith({
    AttendanceModel? todayAttendance,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return AttendanceState(
      todayAttendance: todayAttendance ?? this.todayAttendance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

// ===== NOTIFIER =====
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository _repo;

  AttendanceNotifier(this._repo) : super(AttendanceState()) {
    loadTodayAttendance();
  }

  // Load trạng thái hôm nay khi vào màn hình
  Future<void> loadTodayAttendance() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final attendance = await _repo.getTodayAttendance();
      state = state.copyWith(
        todayAttendance: attendance,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Check In
  Future<void> checkIn() async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _repo.checkIn();
      final attendance = await _repo.getTodayAttendance();
      state = state.copyWith(
        todayAttendance: attendance,
        isLoading: false,
        successMessage: 'Check In thành công!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Check Out
  Future<void> checkOut() async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _repo.checkOut();
      final attendance = await _repo.getTodayAttendance();
      state = state.copyWith(
        todayAttendance: attendance,
        isLoading: false,
        successMessage: 'Check Out thành công!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// ===== PROVIDER =====
final attendanceProvider =
StateNotifierProvider<AttendanceNotifier, AttendanceState>(
      (ref) => AttendanceNotifier(ref.read(attendanceRepositoryProvider)),
);