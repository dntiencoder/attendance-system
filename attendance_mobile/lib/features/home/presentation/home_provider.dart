import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../attendance/domain/attendance_model.dart';
import '../../auth/domain/user_model.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../../core/utils/work_schedule_helper.dart'; // ← thêm import

// ===== STATE =====
class HomeState {
  final UserModel? user;
  final String? departmentName;
  final AttendanceModel? todayAttendance;
  final String selectedShift; // 'day' | 'night'
  
  // Standardized field names to match business logic
  final int monthlyOnTime;
  final int monthlyEarly;
  final int monthlyLate;
  final int monthlyAbsent;
  
  final List<AttendanceModel> recentAttendance;
  final bool isLoading;
  final String? error;

  HomeState({
    this.user,
    this.departmentName,
    this.todayAttendance,
    this.selectedShift = 'day',
    this.monthlyOnTime = 0,
    this.monthlyEarly = 0,
    this.monthlyLate = 0,
    this.monthlyAbsent = 0,
    this.recentAttendance = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    UserModel? user,
    String? departmentName,
    AttendanceModel? todayAttendance,
    String? selectedShift,
    int? monthlyOnTime,
    int? monthlyEarly,
    int? monthlyLate,
    int? monthlyAbsent,
    List<AttendanceModel>? recentAttendance,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      user: user ?? this.user,
      departmentName: departmentName ?? this.departmentName,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      selectedShift: selectedShift ?? this.selectedShift,
      monthlyOnTime: monthlyOnTime ?? this.monthlyOnTime,
      monthlyEarly: monthlyEarly ?? this.monthlyEarly,
      monthlyLate: monthlyLate ?? this.monthlyLate,
      monthlyAbsent: monthlyAbsent ?? this.monthlyAbsent,
      recentAttendance: recentAttendance ?? this.recentAttendance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ===== NOTIFIER =====
class HomeNotifier extends StateNotifier<HomeState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AttendanceRepository _attendanceRepo = AttendanceRepository();

  HomeNotifier() : super(HomeState()) {
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([
        _loadUser(),
        _loadTodayAttendance(),
        _loadMonthlyStats(),
        _loadRecentAttendance(),
      ]);

      // Sau khi load user và attendance, tự động xác định ca nếu chưa check-in
      if (state.todayAttendance == null) {
        await _determineAutoShift();
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _determineAutoShift() async {
    final user = state.user;
    if (user == null) return;

    try {
      final settings = await _attendanceRepo.getCompanySettings();
      final currentShift = settings.getCurrentShift(
        shiftGroup: user.shiftGroup,
        today: DateTime.now(),
      );
      state = state.copyWith(selectedShift: currentShift);
    } catch (e) {
      // Nếu không lấy được settings, giữ mặc định là 'day'
    }
  }

  Future<void> _loadUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      final user = UserModel.fromFirestore(doc);
      state = state.copyWith(user: user);

      // Tải tên phòng ban
      if (user.departmentId.isNotEmpty) {
        final depDoc = await _db
            .collection('departments')
            .doc(user.departmentId)
            .get();
        if (depDoc.exists) {
          state = state.copyWith(
            departmentName: depDoc.data()?['name'],
          );
        }
      }
    }
  }

  Future<void> _loadTodayAttendance() async {
    final attendance = await _attendanceRepo.getTodayAttendance();
    if (attendance != null) {
      state = state.copyWith(
        todayAttendance: attendance,
        selectedShift: attendance.shift,
      );
    }
  }

  Future<void> _loadMonthlyStats() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final snapshot = await _db
        .collection('attendance')
        .where('uid', isEqualTo: uid)
        .where('attendanceDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('attendanceDate',
        isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    final records = snapshot.docs
        .map((doc) => AttendanceModel.fromFirestore(doc))
        .toList();

    final attendanceDates = records
        .where((r) => r.checkIn != null)
        .map((r) => r.attendanceDate)
        .toList();

    // Ngày vắng = ngày làm việc bình thường không có attendance (sử dụng Helper mới)
    final absentDays = WorkScheduleHelper.countAbsentDays(
      month: now,
      attendanceDates: attendanceDates,
    );

    // Đi làm vào ngày thường (không tính tăng ca vào tổng công)
    final onTimeDays = records.where((r) => 
        WorkScheduleHelper.isMandatoryWorkDay(r.attendanceDate) &&
        r.checkIn != null && !r.isLate && !r.isEarlyLeave && r.hasCheckedOut).length;

    state = state.copyWith(
      monthlyOnTime: onTimeDays,
      monthlyEarly: records.where((r) => r.isEarlyLeave).length,
      monthlyLate: records.where((r) => r.isLate).length,
      monthlyAbsent: absentDays,
    );
  }

  Future<void> _loadRecentAttendance() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _db
        .collection('attendance')
        .where('uid', isEqualTo: uid)
        .orderBy('attendanceDate', descending: true)
        .limit(3)
        .get();

    final records = snapshot.docs
        .map((doc) => AttendanceModel.fromFirestore(doc))
        .toList();

    state = state.copyWith(recentAttendance: records);
  }

  void selectShift(String shift) {
    state = state.copyWith(selectedShift: shift);
  }

  Future<void> refresh() => loadHomeData();

  Future<void> loadMonthlyStatsOnly() async {
    await _loadMonthlyStats();
    state = state.copyWith(isLoading: false);
  }

  Future<void> loadRecentAttendanceOnly() async {
    await _loadRecentAttendance();
    state = state.copyWith(isLoading: false);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
      (ref) => HomeNotifier(),
);
