import '../../features/settings/domain/company_settings_model.dart';
import 'rotation_calculator.dart';

/// Xác định "ngày làm việc" (Business Date) và khung giờ ca (Shift Window)
/// cho một thời điểm bất kỳ — điểm neo duy nhất mà mọi quyết định nghiệp vụ
/// chấm công (CheckIn, CheckOut, hiển thị Home) phải dùng chung, thay vì mỗi
/// nơi tự suy luận theo Calendar Date của DateTime.now().
///
/// Xem docs/design/ATTENDANCE_BUSINESS_FLOW.md để biết đầy đủ thuật toán và
/// lý do (ca đêm xuyên nửa đêm thuộc về ngày nó bắt đầu, không phải ngày lịch
/// hiện tại).
class BusinessDateHelper {
  BusinessDateHelper._();

  /// Trả về Business Date (đã chuẩn hoá về 00:00:00) cho thời điểm [now],
  /// dựa trên cấu hình ca [settings] và nhóm ca [shiftGroup] của nhân viên.
  static DateTime resolveBusinessDate(
    DateTime now,
    CompanySettingsModel settings,
    String shiftGroup,
  ) {
    final today = DateTime(now.year, now.month, now.day);

    final nightEndParts = settings.nightShiftEnd.split(':');
    final nightEndHour = int.parse(nightEndParts[0]);
    final nightEndMinute = int.parse(nightEndParts[1]);

    // Ca đêm không xuyên nửa đêm (cấu hình bất thường) -> không có gì để điều chỉnh.
    if (nightEndHour >= 12) {
      return today;
    }

    // Có nằm trong khung giờ sáng sớm [00:00, nightShiftEnd] không?
    final isBeforeOrAtNightEnd = now.hour < nightEndHour ||
        (now.hour == nightEndHour && now.minute <= nightEndMinute);

    if (!isBeforeOrAtNightEnd) {
      return today; // Ngoài khung nhạy cảm -> Calendar Date như bình thường.
    }

    // Trong khung nhạy cảm -> kiểm tra hôm qua nhóm ca này có làm ca đêm không.
    final yesterday = today.subtract(const Duration(days: 1));
    final wasNightYesterday = RotationCalculator.getCurrentShift(
          rotationStartDate: settings.rotationStartDate,
          rotationDays: settings.rotationDays,
          shiftGroup: shiftGroup,
          date: yesterday,
        ) ==
        'night';

    return wasNightYesterday ? yesterday : today;
  }

  /// Trả về mốc bắt đầu/kết thúc (dưới dạng DateTime tuyệt đối) của ca [shift]
  /// diễn ra vào [businessDate]. Tự cộng thêm 1 ngày cho mốc kết thúc nếu ca
  /// xuyên qua nửa đêm (giờ kết thúc <= giờ bắt đầu).
  static ({DateTime start, DateTime end}) resolveShiftWindow(
    DateTime businessDate,
    String shift,
    CompanySettingsModel settings,
  ) {
    final date = DateTime(businessDate.year, businessDate.month, businessDate.day);

    final startParts = settings.getShiftStartTime(shift).split(':');
    final endParts = settings.getShiftEndTime(shift).split(':');

    final start = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );

    var end = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    if (!end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }

    return (start: start, end: end);
  }
}
