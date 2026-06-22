import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/attendance_model.dart';

class AttendanceHistoryState {
  final DateTime selectedMonth;
  final String selectedFilter; // 'all' | 'on_time' | 'late' | 'early' | 'absent'
  final List<AttendanceModel> records;
  final bool isLoading;
  final String? error;

  AttendanceHistoryState({
    required this.selectedMonth,
    this.selectedFilter = 'all',
    this.records = const [],
    this.isLoading = false,
    this.error,
  });

  // Records sau khi lọc
  List<AttendanceModel> get filteredRecords {
    if (selectedFilter == 'all') return records;
    return records.where((r) {
      switch (selectedFilter) {
        case 'on_time': return !r.isLate && !r.isEarlyLeave && r.hasCheckedOut;
        case 'late':    return r.isLate;
        case 'early':   return r.isEarlyLeave;
        case 'absent':  return r.checkIn == null;
        default:        return true;
      }
    }).toList();
  }

  // Thống kê
  int get totalDays  => records.where((r) => r.checkIn != null).length;
  int get earlyDays  => records.where((r) => !r.isLate && r.checkIn != null).length;
  int get lateDays   => records.where((r) => r.isLate).length;
  int get absentDays => records.where((r) => r.checkIn == null).length;

  AttendanceHistoryState copyWith({
    DateTime? selectedMonth,
    String? selectedFilter,
    List<AttendanceModel>? records,
    bool? isLoading,
    String? error,
  }) {
    return AttendanceHistoryState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AttendanceHistoryNotifier
    extends StateNotifier<AttendanceHistoryState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AttendanceHistoryNotifier()
      : super(AttendanceHistoryState(selectedMonth: DateTime.now())) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    final month = state.selectedMonth;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    try {
      final snapshot = await _db
          .collection('attendance')
          .where('uid', isEqualTo: uid)
          .where('attendanceDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('attendanceDate',
          isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('attendanceDate', descending: true)
          .get();

      final records = snapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();

      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void prevMonth() {
    final m = state.selectedMonth;
    state = state.copyWith(
      selectedMonth: DateTime(m.year, m.month - 1),
    );
    loadRecords();
  }

  void nextMonth() {
    final m = state.selectedMonth;
    // Không cho chọn tháng tương lai
    final now = DateTime.now();
    if (m.year == now.year && m.month == now.month) return;
    state = state.copyWith(
      selectedMonth: DateTime(m.year, m.month + 1),
    );
    loadRecords();
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

final attendanceHistoryProvider =
StateNotifierProvider<AttendanceHistoryNotifier, AttendanceHistoryState>(
      (ref) => AttendanceHistoryNotifier(),
);