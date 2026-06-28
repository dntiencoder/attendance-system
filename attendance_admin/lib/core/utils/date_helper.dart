import 'package:intl/intl.dart';

class DateHelper {
  static String toDateString(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static String toDisplayDate(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  static String toDisplayDateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);

  static String toTimeString(DateTime date) =>
      DateFormat('HH:mm').format(date);

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}