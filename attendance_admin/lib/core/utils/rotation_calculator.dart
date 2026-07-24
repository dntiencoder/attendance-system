/// Tính toán ca làm việc theo chu kỳ xoay ca (rotation) -- mirror
/// `attendance_mobile/lib/core/utils/rotation_calculator.dart`, giữ đồng bộ
/// theo CLAUDE.md (shared contract giữa 2 app). Dùng ở admin để suy luận ca
/// của nhân viên cho những ngày không có document `attendance` thật (sinh
/// dòng "Vắng mặt" ảo ở Nhật ký chấm công).
class RotationCalculator {
  RotationCalculator._();

  /// Xác định ca của nhân viên tại [date] (Calendar Date -- admin không có
  /// khái niệm Business Date vì không tự chấm công).
  ///
  /// A = đêm, B = ngày ở chu kỳ chẵn
  /// A = ngày, B = đêm ở chu kỳ lẻ
  static String getCurrentShift({
    required DateTime rotationStartDate,
    required int rotationDays,
    required String shiftGroup,
    required DateTime date,
  }) {
    final normalizedStart = DateTime(rotationStartDate.year, rotationStartDate.month, rotationStartDate.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final daysPassed = normalizedDate.difference(normalizedStart).inDays;

    final rotationIndex = (daysPassed / rotationDays).floor();
    final isFlipped = rotationIndex % 2 != 0;

    if (shiftGroup == 'B') {
      return isFlipped ? 'night' : 'day';
    } else {
      return isFlipped ? 'day' : 'night';
    }
  }
}
