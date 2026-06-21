import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/utils/date_helper.dart';

class DashboardStats {
  final int totalEmployees;
  final int activeEmployees;
  final int todayCheckedIn;
  final int pendingLeaveRequests;
  final int totalDepartments;
  final List<DailyAttendanceCount> weeklyAttendance;

  DashboardStats({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.todayCheckedIn,
    required this.pendingLeaveRequests,
    required this.totalDepartments,
    required this.weeklyAttendance,
  });

  double get attendanceRate =>
      activeEmployees == 0 ? 0 : (todayCheckedIn / activeEmployees) * 100;
}

class DailyAttendanceCount {
  final DateTime date;
  final int count;

  DailyAttendanceCount({required this.date, required this.count});
}

class DashboardRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DashboardStats> getDashboardStats() async {
    final usersSnap = await _db
        .collection('users')
        .where('role', isEqualTo: AppConfig.roleEmployee)
        .get();

    final totalEmployees = usersSnap.docs.length;
    final activeEmployees =
        usersSnap.docs.where((d) => d.data()['isActive'] == true).length;

    final departmentsSnap = await _db.collection('departments').get();

    final today = DateTime.now();
    final startOfToday = Timestamp.fromDate(DateTime(today.year, today.month, today.day));
    
    final todayAttendanceSnap = await _db
        .collection('attendance')
        .where('attendanceDate', isEqualTo: startOfToday)
        .get();

    final pendingLeaveSnap = await _db
        .collection('leave_requests')
        .where('status', isEqualTo: AppConfig.statusPending)
        .get();

    final weeklyAttendance = await _getWeeklyAttendance();

    return DashboardStats(
      totalEmployees: totalEmployees,
      activeEmployees: activeEmployees,
      todayCheckedIn: todayAttendanceSnap.docs.length,
      pendingLeaveRequests: pendingLeaveSnap.docs.length,
      totalDepartments: departmentsSnap.docs.length,
      weeklyAttendance: weeklyAttendance,
    );
  }

  /// Đếm số lượt chấm công của 7 ngày gần nhất (tính cả hôm nay) để vẽ biểu đồ
  Future<List<DailyAttendanceCount>> _getWeeklyAttendance() async {
    final now = DateTime.now();
    final results = <DailyAttendanceCount>[];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final startOfDay = Timestamp.fromDate(DateTime(day.year, day.month, day.day));
      final snap = await _db
          .collection('attendance')
          .where('attendanceDate', isEqualTo: startOfDay)
          .get();
      results.add(DailyAttendanceCount(date: day, count: snap.docs.length));
    }

    return results;
  }
}