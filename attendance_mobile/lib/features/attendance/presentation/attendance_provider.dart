import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/attendance_repository.dart';
import '../domain/attendance_model.dart';
import '../../../core/utils/business_date_helper.dart';
import '../../../core/services/clock_service.dart';

// Provider cho repository
final attendanceRepositoryProvider = Provider<AttendanceRepository>(
      (ref) => AttendanceRepository(),
);

// ===== STATE =====
class AttendanceState {
  final AttendanceModel? todayAttendance;
  final bool isLoading;
  final bool isShiftEnded;
  final String? error;
  final String? successMessage;

  AttendanceState({
    this.todayAttendance,
    this.isLoading = false,
    this.isShiftEnded = false,
    this.error,
    this.successMessage,
  });

  AttendanceState copyWith({
    AttendanceModel? todayAttendance,
    bool? isLoading,
    bool? isShiftEnded,
    String? error,
    String? successMessage,
  }) {
    return AttendanceState(
      todayAttendance: todayAttendance ?? this.todayAttendance,
      isLoading: isLoading ?? this.isLoading,
      isShiftEnded: isShiftEnded ?? this.isShiftEnded,
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
    state = state.copyWith(isLoading: true, error: null, isShiftEnded: false);
    try {
      final attendance = await _repo.getTodayAttendance();
      
      // Kiểm tra nếu chưa chấm công thì xem đã hết ca chưa
      bool shiftEnded = false;
      if (attendance == null) {
        final settings = await _repo.getCompanySettings();
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(
            FirebaseAuth.instance.currentUser?.uid).get();
        final shiftGroup = userDoc.data()?['shiftGroup'] ?? 'A';

        final now = ClockService.now();
        final businessDate = BusinessDateHelper.resolveBusinessDate(now, settings, shiftGroup);
        final currentShift = settings.getCurrentShift(shiftGroup: shiftGroup, today: businessDate);
        final window = BusinessDateHelper.resolveShiftWindow(businessDate, currentShift, settings);

        shiftEnded = now.isAfter(window.end);
      }

      state = state.copyWith(
        todayAttendance: attendance,
        isLoading: false,
        isShiftEnded: shiftEnded,
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
      final isShiftEndedError = e.toString().contains('Ca làm việc đã kết thúc');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
        isShiftEnded: isShiftEndedError,
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