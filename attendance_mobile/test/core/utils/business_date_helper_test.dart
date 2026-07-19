// Unit test cho BusinessDateHelper.resolveBusinessDate() — UT-12, UT-13, UT-14
// (docs/testing/01_TEST_PLAN.md mục A). Mốc 00:15 khớp với kịch bản đã ghi ở
// docs/demo/DEMO_GUIDE.md mục 3.2 (điểm chứng minh Business Date quan trọng nhất).

import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_app/core/utils/business_date_helper.dart';
import 'package:attendance_app/features/settings/domain/company_settings_model.dart';

CompanySettingsModel _buildSettings() {
  return CompanySettingsModel(
    id: 'main',
    companyName: 'Test Co',
    latitude: 21.0285,
    longitude: 105.7848,
    radius: 500,
    dayShiftStart: '08:00',
    dayShiftEnd: '20:00',
    nightShiftStart: '20:00',
    nightShiftEnd: '08:00',
    rotationDays: 14,
    // Khối 1 (2026-01-01 .. 2026-01-14): nhóm A làm đêm, nhóm B làm ngày.
    rotationStartDate: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  final settings = _buildSettings();

  test('UT-12: sự kiện lúc 23:59 -> vẫn là ngày làm việc hiện tại (ngoài khung nhạy cảm)', () {
    final now = DateTime(2026, 1, 5, 23, 59);
    final businessDate = BusinessDateHelper.resolveBusinessDate(now, settings, 'A');
    expect(businessDate, DateTime(2026, 1, 5));
  });

  test('UT-13: sự kiện lúc 00:00, nhóm làm đêm hôm qua -> resolve về hôm qua', () {
    final now = DateTime(2026, 1, 6, 0, 0);
    // Nhóm A làm đêm suốt khối 1 (bao gồm 2026-01-05) -> business date = hôm qua.
    final businessDate = BusinessDateHelper.resolveBusinessDate(now, settings, 'A');
    expect(businessDate, DateTime(2026, 1, 5));
  });

  test('UT-14: sự kiện lúc 00:15 (mốc DEMO_GUIDE), nhóm làm đêm hôm qua -> vẫn resolve về hôm qua', () {
    final now = DateTime(2026, 1, 6, 0, 15);
    final businessDate = BusinessDateHelper.resolveBusinessDate(now, settings, 'A');
    expect(businessDate, DateTime(2026, 1, 5));
  });

  test('UT-14 (đối chứng): cùng mốc 00:15 nhưng nhóm làm ngày hôm qua -> resolve về hôm nay', () {
    final now = DateTime(2026, 1, 6, 0, 15);
    // Nhóm B làm ngày suốt khối 1 -> không có ca đêm nào đang dở dang -> hôm nay.
    final businessDate = BusinessDateHelper.resolveBusinessDate(now, settings, 'B');
    expect(businessDate, DateTime(2026, 1, 6));
  });
}
