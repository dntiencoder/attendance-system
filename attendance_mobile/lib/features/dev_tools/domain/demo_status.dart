import '../../attendance/data/attendance_repository.dart';
import '../../settings/domain/company_settings_model.dart';
import '../../../core/services/clock_service.dart';
import '../../../core/utils/business_date_helper.dart';

/// Business Date + Shift hiện tại theo ClockService.now(), dùng chung cho
/// DemoModeBanner và khối "Thông tin hiện tại" trong DemoCenterScreen — để
/// không viết lặp lại logic BusinessDateHelper/getCurrentShift ở 2 nơi.
class DemoStatus {
  final DateTime businessDate;
  final String shift; // 'day' | 'night'

  const DemoStatus({required this.businessDate, required this.shift});

  String get shiftLabel => shift == 'night' ? 'Ca đêm' : 'Ca ngày';
}

class DemoStatusResolver {
  DemoStatusResolver._();

  static Future<DemoStatus> resolve(String shiftGroup) async {
    final settings = await AttendanceRepository().getCompanySettings();
    return resolveWithSettings(settings, shiftGroup);
  }

  static DemoStatus resolveWithSettings(
    CompanySettingsModel settings,
    String shiftGroup,
  ) {
    final now = ClockService.now();
    final businessDate = BusinessDateHelper.resolveBusinessDate(
      now,
      settings,
      shiftGroup,
    );
    final shift = settings.getCurrentShift(
      shiftGroup: shiftGroup,
      today: businessDate,
    );
    return DemoStatus(businessDate: businessDate, shift: shift);
  }
}
