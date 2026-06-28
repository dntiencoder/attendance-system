import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/attendance_model.dart';
import '../../settings/domain/company_settings_model.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/utils/work_schedule_helper.dart'; // ← thêm import

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

  // Thống kê - Luôn đảm bảo không null
  int get onTimeDays => records.where((r) => r.checkIn != null && !r.isLate && !r.isEarlyLeave && r.hasCheckedOut).length;
  int get earlyLeaveDays => records.where((r) => r.isEarlyLeave).length;
  int get lateDays => records.where((r) => r.isLate).length;
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

      final List<AttendanceModel> records = snapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();

      // Logic Tự động ghi nhận Vắng mặt (Absent Generation)
      final List<AttendanceModel> allDaysRecords = [];
      final now = DateTime.now();
      final lastDayToFill = (month.year == now.year && month.month == now.month)
          ? now.day
          : end.day;

      // Lấy cấu hình công ty để xác định ca cho các ngày vắng
      final settingsDoc = await _db.collection('company_settings').doc(AppConfig.companySettingsDocId).get();
      final settings = CompanySettingsModel.fromFirestore(settingsDoc);
      
      // Lấy nhóm ca của user
      final userDoc = await _db.collection('users').doc(uid).get();
      final shiftGroup = userDoc.data()?['shiftGroup'] ?? 'A';

      for (int day = 1; day <= lastDayToFill; day++) {
        final date = DateTime(month.year, month.month, day);
        
        // Tìm xem ngày này đã có record chưa
        final existing = records.firstWhere(
          (r) => r.attendanceDate.day == day && 
                 r.attendanceDate.month == month.month && 
                 r.attendanceDate.year == month.year,
          orElse: () => AttendanceModel(
            id: 'virtual_$day',
            uid: uid,
            employeeCode: '', 
            shift: settings.getCurrentShift(shiftGroup: shiftGroup, today: date),
            attendanceDate: date,
            latitude: 0,
            longitude: 0,
            distance: 0,
            isLate: false,
            isEarlyLeave: false,
            status: 'absent',
            createdAt: date,
          ),
        );

        // NẾU LÀ RECORD VIRTUAL (không đi làm), 
        // CHỈ ADD VÀO LIST NẾU ĐÓ LÀ NGÀY BẮT BUỘC ĐI LÀM (Work Day)
        if (existing.id.startsWith('virtual_')) {
           if (WorkScheduleHelper.isMandatoryWorkDay(date)) {
             allDaysRecords.add(existing);
           }
        } else {
          // Record thật (đã chấm công hoặc tăng ca) thì luôn add
          allDaysRecords.add(existing);
        }
      }

      // Sắp xếp lại từ mới nhất đến cũ nhất
      allDaysRecords.sort((a, b) => b.attendanceDate.compareTo(a.attendanceDate));

      state = state.copyWith(records: allDaysRecords, isLoading: false);
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
