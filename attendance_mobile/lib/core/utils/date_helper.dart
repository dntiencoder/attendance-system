import 'package:intl/intl.dart';

class DateHelper {
  // "2024-01-15"
  static String toDateString(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  // "08:30"
  static String toTimeString(DateTime date) =>
      DateFormat('HH:mm').format(date);

  // "15/01/2024"
  static String toDisplayDate(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  // "15/01/2024 08:30"
  static String toDisplayDateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);

  // Lấy đầu ngày (00:00:00)
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  // Lấy cuối ngày (23:59:59)
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  // Lấy tên Thứ bằng tiếng Việt
  static String getWeekdayName(DateTime date) {
    const days = [
      'Chủ Nhật',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
    ];
    // DateTime.weekday: 1 (Mon) -> 7 (Sun)
    // Mảng của mình: 0 (Sun) -> 6 (Sat)
    return days[date.weekday % 7];
  }
}