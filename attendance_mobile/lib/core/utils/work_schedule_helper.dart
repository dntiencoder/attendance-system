import 'package:flutter/material.dart';

class WorkScheduleHelper {
  WorkScheduleHelper._();

  // Ngày gốc cố định khớp với Seeder (Thứ Hai 01/06/2026)
  static final DateTime _baseRotationDate = DateTime(2026, 6, 1);

  /// Kiểm tra xem ngày hiện tại có thuộc "Tuần lẻ" trong chu kỳ 14 ngày không
  /// Tuần lẻ: Tuần đi làm Thứ 7 (W1, W3, W5...)
  /// Tuần chẵn: Tuần xoay ca, Thứ 7 tính tăng ca (W2, W4, W6...)
  static bool isOddWeek(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final daysPassed = normalizedDate.difference(_baseRotationDate).inDays;
    
    // totalWeeks: Tổng số tuần đã trôi qua kể từ ngày gốc
    final totalWeeks = daysPassed ~/ 7;
    
    // Tuần 0, 2, 4... là tuần lẻ (Work Saturday)
    // Tuần 1, 3, 5... là tuần chẵn (Rotation Week - OT Saturday)
    return totalWeeks % 2 == 0;
  }

  /// Xác định loại ngày: 'work' | 'overtime' | 'off'
  static String getDayType(DateTime date) {
    final weekday = date.weekday;
    final oddWeek = isOddWeek(date);

    if (oddWeek) {
      // Tuần Lẻ (Tuần làm Thứ 7)
      if (weekday >= 1 && weekday <= 6) return 'work';
      if (weekday == 7) return 'overtime';
    } else {
      // Tuần Chẵn (Tuần Xoay ca)
      if (weekday >= 1 && weekday <= 5) return 'work';
      if (weekday == 6) return 'overtime';
      if (weekday == 7) return 'off';
    }

    return 'off';
  }

  // Loại bỏ hàm weekOfMonth cũ vì nó không phản ánh đúng chu kỳ xoay ca 14 ngày của UMC


  static bool isMandatoryWorkDay(DateTime date) => getDayType(date) == 'work';

  static bool isOvertimeDay(DateTime date) => getDayType(date) == 'overtime';

  static bool isOffDay(DateTime date) => getDayType(date) == 'off';

  /// Label hiển thị loại ngày (Tiếng Việt)
  static String getDayTypeLabel(DateTime date) {
    switch (getDayType(date)) {
      case 'work':
        return 'Ngày làm';
      case 'overtime':
        return 'Tăng ca';
      case 'off':
        return 'Nghỉ';
      default:
        return '';
    }
  }

  /// Đếm số ngày vắng trong tháng
  /// Chỉ tính cho những "Ngày làm bình thường" đã qua mà không có dữ liệu chấm công
  static int countAbsentDays({
    required DateTime month,
    required List<DateTime> attendanceDates,
  }) {
    final now = DateTime.now();
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    int absent = 0;

    for (int d = 1; d <= lastDay; d++) {
      final date = DateTime(month.year, month.month, d);

      // Chỉ tính các ngày đã qua (bao gồm cả hôm nay nếu chưa chấm công)
      if (date.isAfter(now)) break;

      // Chỉ xét ngày làm việc bình thường (bắt buộc)
      if (!isMandatoryWorkDay(date)) continue;

      // Kiểm tra xem ngày này đã có bản ghi chấm công chưa
      final hasAttendance = attendanceDates.any((a) =>
          a.year == date.year && a.month == date.month && a.day == date.day);

      if (!hasAttendance) {
        absent++;
      }
    }

    return absent;
  }
}
