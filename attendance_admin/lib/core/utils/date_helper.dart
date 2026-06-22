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
}