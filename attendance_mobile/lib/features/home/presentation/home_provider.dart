import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../attendance/domain/attendance_model.dart';
import '../../auth/domain/user_model.dart';
import '../../attendance/data/attendance_repository.dart';

// ===== STATE =====
class HomeState {
  final UserModel? user;
  final AttendanceModel? todayAttendance;
  final String selectedShift; // 'day' | 'night'
  final int monthlyTotal;
  final int monthlyEarly;
  final int monthlyLate;
  final int monthlyLeave;
  final List<AttendanceModel> recentAttendance;
  final bool isLoading;
  final String? error;

  HomeState({
    this.user,
    this.todayAttendance,
    this.selectedShift = 'day',
    this.monthlyTotal = 0,
    this.monthlyEarly = 0,
    this.monthlyLate = 0,
    this.monthlyLeave = 0,
    this.recentAttendance = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    UserModel? user,
    AttendanceModel? todayAttendance,
    String? selectedShift,
    int? monthlyTotal,
    int? monthlyEarly,
    int? monthlyLate,
    int? monthlyLeave,
    List<AttendanceModel>? recentAttendance,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      user: user ?? this.user,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      selectedShift: selectedShift ?? this.selectedShift,
      monthlyTotal: monthlyTotal ?? this.monthlyTotal,
      monthlyEarly: monthlyEarly ?? this.monthlyEarly,
      monthlyLate: monthlyLate ?? this.monthlyLate,
      monthlyLeave: monthlyLeave ?? this.monthlyLeave,
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
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _loadUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      state = state.copyWith(user: UserModel.fromFirestore(doc));
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

    // Lấy số ngày nghỉ
    final leaveSnapshot = await _db
        .collection('leave_requests')
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: 'approved')
        .get();

    state = state.copyWith(
      monthlyTotal: records.length,
      monthlyEarly: records.where((r) => r.isEarlyLeave).length,
      monthlyLate: records.where((r) => r.isLate).length,
      monthlyLeave: leaveSnapshot.docs.length,
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