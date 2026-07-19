import '../../features/settings/domain/company_settings_model.dart';
import 'business_date_helper.dart';
import '../services/clock_service.dart';

class WorkScheduleHelper {
  WorkScheduleHelper._();

  /// Kiểm tra xem [date] có thuộc "Tuần lẻ" không, tính theo số tuần đã trôi
  /// qua kể từ [rotationStartDate] — PHẢI lấy từ `CompanySettingsModel`
  /// (nguồn duy nhất cho mốc ngày gốc, xem docs/decision/01_DECISION_LOG.md),
  /// không hardcode trong hàm này nữa. Đây là câu hỏi nghiệp vụ khác với
  /// "ca A/B hôm nay là ngày hay đêm" (RotationCalculator.getCurrentShift) —
  /// chỉ tình cờ dùng chung 1 mốc ngày gốc, không phải cùng 1 phép tính.
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

    // totalWeeks: Tổng số tuần đã trôi qua kể từ ngày gốc
    final totalWeeks = daysPassed ~/ 7;

    // Tuần 0, 2, 4... là tuần lẻ (Work Saturday)
    // Tuần 1, 3, 5... là tuần chẵn (Rotation Week - OT Saturday)
    return totalWeeks % 2 == 0;
  }

  /// Xác định loại ngày: 'work' | 'overtime' | 'off'
  static String getDayType(DateTime date, DateTime rotationStartDate) {
    final weekday = date.weekday;
    final oddWeek = isOddWeek(date, rotationStartDate);

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


  static bool isMandatoryWorkDay(DateTime date, DateTime rotationStartDate) =>
      getDayType(date, rotationStartDate) == 'work';

  static bool isOvertimeDay(DateTime date, DateTime rotationStartDate) =>
      getDayType(date, rotationStartDate) == 'overtime';

  static bool isOffDay(DateTime date, DateTime rotationStartDate) =>
      getDayType(date, rotationStartDate) == 'off';

  /// Label hiển thị loại ngày (Tiếng Việt)
  static String getDayTypeLabel(DateTime date, DateTime rotationStartDate) {
    switch (getDayType(date, rotationStartDate)) {
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
    required String shiftGroup,
    required CompanySettingsModel settings,
  }) {
    final now = BusinessDateHelper.resolveBusinessDate(
      ClockService.now(),
      settings,
      shiftGroup,
    );
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    int absent = 0;

    for (int d = 1; d <= lastDay; d++) {
      final date = DateTime(month.year, month.month, d);

      // Chỉ tính các ngày đã qua (bao gồm cả hôm nay nếu chưa chấm công)
      if (date.isAfter(now)) break;

      // Chỉ xét ngày làm việc bình thường (bắt buộc)
      if (!isMandatoryWorkDay(date, settings.rotationStartDate)) continue;

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
