/// Tính toán ca làm việc theo chu kỳ xoay ca (rotation), tách riêng khỏi
/// CompanySettingsModel để có thể unit test độc lập, không cần dựng cả model.
class RotationCalculator {
  RotationCalculator._();

  /// Xác định ca hiện tại của nhân viên tại [date] (phải là Business Date,
  /// không phải DateTime.now() thô).
  ///
  /// A = đêm, B = ngày ở chu kỳ chẵn
  /// A = ngày, B = đêm ở chu kỳ lẻ
  static String getCurrentShift({
    required DateTime rotationStartDate,
    required int rotationDays,
    required String shiftGroup,
    required DateTime date,
  }) {
    // 1. Chuẩn hóa ngày về 00:00:00
    final normalizedStart = DateTime(rotationStartDate.year, rotationStartDate.month, rotationStartDate.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // 2. Tính số ngày đã trôi qua
    final daysPassed = normalizedDate.difference(normalizedStart).inDays;

    // 3. Logic rotationDays ngày đổi 1 lần:
    // rotationIndex: cho biết đang ở khối rotationDays ngày thứ mấy
    // index 0 (ngày 0..rotationDays-1): Khối 1
    // index 1 (ngày rotationDays..2*rotationDays-1): Khối 2
    final rotationIndex = (daysPassed / rotationDays).floor();

    // 4. Xác định trạng thái lật ca (Toggle)
    final isFlipped = rotationIndex % 2 != 0;

    // 5. Áp dụng quy tắc (Theo yêu cầu: Tuần này/trước (Khối 2) B làm Đêm)
    // Khối 1 (0-13): B làm Ngày, A làm Đêm
    // Khối 2 (14-27): B làm Đêm, A làm Ngày
    if (shiftGroup == 'B') {
      return isFlipped ? 'night' : 'day';
    } else {
      return isFlipped ? 'day' : 'night';
    }
  }
}
