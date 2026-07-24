/// Xác định ngày làm bắt buộc theo lịch xoay tuần -- mirror phần
/// `isMandatoryWorkDay`/`getDayType`/`isOddWeek` của
/// `attendance_mobile/lib/core/utils/work_schedule_helper.dart`, giữ đồng bộ
/// theo CLAUDE.md (shared contract giữa 2 app). Chỉ port đúng phần admin cần
/// (sinh dòng "Vắng mặt" ảo ở Nhật ký chấm công) -- không port
/// `countAbsentDays`/`isOffDay`/`isOvertimeDay` vì phụ thuộc Business
/// Date/ClockService, admin không cần.
class WorkScheduleHelper {
  WorkScheduleHelper._();

  /// Tuần lẻ: Tuần đi làm Thứ 7 (W1, W3, W5...)
  /// Tuần chẵn: Tuần xoay ca, Thứ 7 tính tăng ca (W2, W4, W6...)
  static bool isOddWeek(DateTime date, DateTime rotationStartDate) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(
      rotationStartDate.year,
      rotationStartDate.month,
      rotationStartDate.day,
    );
    final daysPassed = normalizedDate.difference(normalizedStart).inDays;
    final totalWeeks = daysPassed ~/ 7;

    return totalWeeks % 2 == 0;
  }

  /// Xác định loại ngày: 'work' | 'overtime' | 'off'
  static String getDayType(DateTime date, DateTime rotationStartDate) {
    final weekday = date.weekday;
    final oddWeek = isOddWeek(date, rotationStartDate);

    if (oddWeek) {
      if (weekday >= 1 && weekday <= 6) return 'work';
      if (weekday == 7) return 'overtime';
    } else {
      if (weekday >= 1 && weekday <= 5) return 'work';
      if (weekday == 6) return 'overtime';
      if (weekday == 7) return 'off';
    }

    return 'off';
  }

  static bool isMandatoryWorkDay(DateTime date, DateTime rotationStartDate) =>
      getDayType(date, rotationStartDate) == 'work';
}
