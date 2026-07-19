// Unit test cho RotationCalculator.getCurrentShift() — UT-04, UT-05
// (docs/testing/01_TEST_PLAN.md mục A).

import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_app/core/utils/rotation_calculator.dart';

void main() {
  // Khối 1 (daysPassed 0-13): B làm ngày, A làm đêm.
  // Khối 2 (daysPassed 14-27): B làm đêm, A làm ngày.
  final rotationStartDate = DateTime(2026, 1, 1);
  const rotationDays = 14;

  String shiftOf(String group, DateTime date) => RotationCalculator.getCurrentShift(
        rotationStartDate: rotationStartDate,
        rotationDays: rotationDays,
        shiftGroup: group,
        date: date,
      );

  test('UT-04: đúng ngày đổi ca (daysPassed % rotationDays == 0), A/B đảo vai trò', () {
    // 2026-01-15 = daysPassed 14 -> đầu khối 2, đúng mốc đổi ca.
    final flipDay = DateTime(2026, 1, 15);
    expect(shiftOf('A', flipDay), 'day');
    expect(shiftOf('B', flipDay), 'night');
  });

  test('UT-05: 1 ngày trước mốc đổi ca vẫn giữ nguyên ca của khối cũ', () {
    // 2026-01-14 = daysPassed 13 -> vẫn thuộc khối 1.
    final dayBeforeFlip = DateTime(2026, 1, 14);
    expect(shiftOf('A', dayBeforeFlip), 'night');
    expect(shiftOf('B', dayBeforeFlip), 'day');
  });

  test('UT-05: 1 ngày sau mốc đổi ca không đổi thêm lần nữa', () {
    // 2026-01-16 = daysPassed 15 -> vẫn thuộc khối 2, giống hệt ngày đổi ca.
    final dayAfterFlip = DateTime(2026, 1, 16);
    expect(shiftOf('A', dayAfterFlip), 'day');
    expect(shiftOf('B', dayAfterFlip), 'night');
  });
}
