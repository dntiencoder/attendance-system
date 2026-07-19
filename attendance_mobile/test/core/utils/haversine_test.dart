// Unit test cho Haversine.calculateDistance()/isWithinRadius() — UT-01, UT-02,
// UT-03 (docs/testing/01_TEST_PLAN.md mục A).

import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_app/core/utils/haversine.dart';

void main() {
  group('Haversine.calculateDistance', () {
    test('UT-01: cùng tọa độ trả về khoảng cách 0', () {
      final distance = Haversine.calculateDistance(21.0285, 105.7848, 21.0285, 105.7848);
      expect(distance, 0);
    });

    test('UT-03: khoảng cách rất lớn (khác lục địa) không tràn số, hợp lý', () {
      // Hà Nội <-> New York, thực tế ~ 13.000 km
      final distance = Haversine.calculateDistance(21.0285, 105.7848, 40.7128, -74.0060);
      expect(distance.isFinite, isTrue);
      expect(distance, greaterThan(12000000));
      expect(distance, lessThan(14000000));
    });
  });

  group('Haversine.isWithinRadius', () {
    test('UT-02: khoảng cách đúng bằng bán kính (biên) vẫn tính là trong phạm vi (<=)', () {
      expect(Haversine.isWithinRadius(500.0, 500.0), isTrue);
    });

    test('UT-02: khoảng cách vượt bán kính dù chỉ một chút thì bị coi là ngoài phạm vi', () {
      expect(Haversine.isWithinRadius(500.01, 500.0), isFalse);
    });
  });
}
