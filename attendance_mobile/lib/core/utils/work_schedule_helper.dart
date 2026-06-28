import 'package:flutter/material.dart';

class WorkScheduleHelper {
  WorkScheduleHelper._();

  /// Tính tuần thứ mấy trong tháng (1-based)
  /// Tuần 1 = từ ngày 1 đến hết ngày thứ 7 đầu tiên
  static int weekOfMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    // Điều chỉnh để Thứ 2 là ngày bắt đầu tuần theo logic Việt Nam (weekday: 1=T2, 7=CN)
    // Logic của bạn: Tuần 1 bắt đầu từ ngày 1.
    return ((date.day + firstDay.weekday - 2) / 7).floor() + 1;
  }

  /// Kiểm tra Tuần lẻ hay Tuần chẵn
  static bool isOddWeek(DateTime date) {
    return weekOfMonth(date) % 2 != 0;
  }

  /// Xác định loại ngày: 'work' (Ngày làm bình thường) | 'overtime' (Tăng ca) | 'off' (Nghỉ bắt buộc)
  static String getDayType(DateTime date) {
    final weekday = date.weekday; // 1=T2, 6=T7, 7=CN
    final oddWeek = isOddWeek(date);

    if (oddWeek) {
      // Tuần lẻ — KHÔNG chuyển ca
      // Thứ 2 -> Thứ 7: Ngày làm việc bình thường
      if (weekday >= 1 && weekday <= 6) return 'work';
      // Chủ nhật: Tăng ca tự nguyện
      if (weekday == 7) return 'overtime';
    } else {
      // Tuần chẵn — CHUYỂN GIAO CA
      // Thứ 2 -> Thứ 6: Ngày làm việc bình thường
      if (weekday >= 1 && weekday <= 5) return 'work';
      // Thứ 7: Tăng ca tự nguyện
      if (weekday == 6) return 'overtime';
      // Chủ nhật: Nghỉ bắt buộc
      if (weekday == 7) return 'off';
    }

    return 'off';
  }

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
