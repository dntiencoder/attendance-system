// Unit test cho CompanySettingsModel.calculateIsLate()/calculateEarlyLeave()
// — UT-06 đến UT-11 (docs/testing/01_TEST_PLAN.md mục A).

import 'package:flutter_test/flutter_test.dart';
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
    rotationStartDate: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  final settings = _buildSettings();

  group('calculateIsLate', () {
    test('UT-06: check-in đúng giờ bắt đầu ca -> không muộn', () {
      final window = (start: DateTime(2026, 1, 5, 8, 0), end: DateTime(2026, 1, 5, 20, 0));
      final isLate = settings.calculateIsLate(checkInTime: window.start, window: window);
      expect(isLate, isFalse);
    });

    test('UT-07: check-in trễ 1 phút -> muộn', () {
      final window = (start: DateTime(2026, 1, 5, 8, 0), end: DateTime(2026, 1, 5, 20, 0));
      final checkIn = window.start.add(const Duration(minutes: 1));
      expect(settings.calculateIsLate(checkInTime: checkIn, window: window), isTrue);
    });

    test('UT-07: check-in trễ nhiều -> muộn', () {
      final window = (start: DateTime(2026, 1, 5, 8, 0), end: DateTime(2026, 1, 5, 20, 0));
      final checkIn = window.start.add(const Duration(hours: 2));
      expect(settings.calculateIsLate(checkInTime: checkIn, window: window), isTrue);
    });

    test('UT-08: ca đêm, check-in ngay trước nửa đêm -> vẫn tính đúng theo window, không lệch ngày', () {
      // Window ca đêm: bắt đầu 20:00 hôm nay, kết thúc 08:00 hôm sau.
      final window = (
        start: DateTime(2026, 1, 5, 20, 0),
        end: DateTime(2026, 1, 6, 8, 0),
      );
      final checkIn = DateTime(2026, 1, 5, 23, 59);
      expect(settings.calculateIsLate(checkInTime: checkIn, window: window), isTrue);
      // Đúng giờ bắt đầu ca đêm thì không muộn.
      expect(settings.calculateIsLate(checkInTime: window.start, window: window), isFalse);
    });
  });

  group('calculateEarlyLeave', () {
    test('UT-09: check-out đúng giờ kết thúc ca -> không về sớm', () {
      final window = (start: DateTime(2026, 1, 5, 8, 0), end: DateTime(2026, 1, 5, 20, 0));
      expect(settings.calculateEarlyLeave(checkOutTime: window.end, window: window), isFalse);
    });

    test('UT-09: check-out sau giờ kết thúc ca -> không về sớm', () {
      final window = (start: DateTime(2026, 1, 5, 8, 0), end: DateTime(2026, 1, 5, 20, 0));
      final checkOut = window.end.add(const Duration(minutes: 10));
      expect(settings.calculateEarlyLeave(checkOutTime: checkOut, window: window), isFalse);
    });

    test('UT-10: check-out sớm -> về sớm', () {
      final window = (start: DateTime(2026, 1, 5, 8, 0), end: DateTime(2026, 1, 5, 20, 0));
      final checkOut = window.end.subtract(const Duration(minutes: 30));
      expect(settings.calculateEarlyLeave(checkOutTime: checkOut, window: window), isTrue);
    });

    test('UT-11: ca đêm, check-out sau khi qua nửa đêm (ngày lịch hôm sau) vẫn tính đúng cho ca hôm trước', () {
      final window = (
        start: DateTime(2026, 1, 5, 20, 0),
        end: DateTime(2026, 1, 6, 8, 0),
      );
      // 00:15 hôm sau -- vẫn trước giờ tan ca -> về sớm.
      final earlyCheckOut = DateTime(2026, 1, 6, 0, 15);
      expect(settings.calculateEarlyLeave(checkOutTime: earlyCheckOut, window: window), isTrue);
      // Đúng giờ tan ca -> không về sớm.
      expect(settings.calculateEarlyLeave(checkOutTime: window.end, window: window), isFalse);
    });
  });
}
