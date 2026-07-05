import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/rotation_calculator.dart';

class CompanySettingsModel {
  final String id;

  final String companyName;

  final double latitude;
  final double longitude;
  final double radius;

  // Ca ngày
  final String dayShiftStart;
  final String dayShiftEnd;

  // Ca đêm
  final String nightShiftStart;
  final String nightShiftEnd;

  // Chu kỳ đổi ca
  final int rotationDays;

  // Ngày bắt đầu tính chu kỳ
  final DateTime rotationStartDate;

  final DateTime updatedAt;

  const CompanySettingsModel({
    required this.id,
    required this.companyName,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.dayShiftStart,
    required this.dayShiftEnd,
    required this.nightShiftStart,
    required this.nightShiftEnd,
    required this.rotationDays,
    required this.rotationStartDate,
    required this.updatedAt,
  });

  factory CompanySettingsModel.fromFirestore(
      DocumentSnapshot doc,
      ) {
    final data = doc.data() as Map<String, dynamic>;

    return CompanySettingsModel(
      id: doc.id,

      companyName: data['companyName'] ?? '',

      latitude: (data['latitude'] ?? 0).toDouble(),

      longitude: (data['longitude'] ?? 0).toDouble(),

      radius: (data['radius'] ?? 100).toDouble(),

      dayShiftStart: data['dayShiftStart'] ?? '08:00',

      dayShiftEnd: data['dayShiftEnd'] ?? '20:00',

      nightShiftStart: data['nightShiftStart'] ?? '20:00',

      nightShiftEnd: data['nightShiftEnd'] ?? '08:00',

      rotationDays: data['rotationDays'] ?? 14,

      rotationStartDate:
      data['rotationStartDate'] != null
          ? (data['rotationStartDate']
      as Timestamp)
          .toDate()
          : DateTime.now(),

      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp)
          .toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'companyName': companyName,

      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,

      'dayShiftStart': dayShiftStart,
      'dayShiftEnd': dayShiftEnd,

      'nightShiftStart': nightShiftStart,
      'nightShiftEnd': nightShiftEnd,

      'rotationDays': rotationDays,

      'rotationStartDate':
      Timestamp.fromDate(rotationStartDate),

      'updatedAt':
      Timestamp.fromDate(updatedAt),
    };
  }

  /// Xác định ca hiện tại của nhân viên
  ///
  /// A = đêm, B = ngày ở chu kỳ chẵn
  /// A = ngày, B = đêm ở chu kỳ lẻ
  String getCurrentShift({
    required String shiftGroup,
    required DateTime today,
  }) {
    return RotationCalculator.getCurrentShift(
      rotationStartDate: rotationStartDate,
      rotationDays: rotationDays,
      shiftGroup: shiftGroup,
      date: today,
    );
  }

  /// Lấy giờ bắt đầu ca
  String getShiftStartTime(
      String shift,
      ) {
    return shift == 'day'
        ? dayShiftStart
        : nightShiftStart;
  }

  /// Lấy giờ kết thúc ca
  String getShiftEndTime(
      String shift,
      ) {
    return shift == 'day'
        ? dayShiftEnd
        : nightShiftEnd;
  }

  /// Kiểm tra đi muộn. [window] là Shift Window đã được resolve sẵn qua
  /// BusinessDateHelper.resolveShiftWindow() — neo theo Business Date, không
  /// phải theo ngày lịch của [checkInTime] (tránh sai lệch quanh nửa đêm với
  /// ca đêm — xem docs/design/ATTENDANCE_BUSINESS_FLOW.md).
  bool calculateIsLate({
    required DateTime checkInTime,
    required ({DateTime start, DateTime end}) window,
  }) {
    return checkInTime.isAfter(window.start);
  }

  /// Kiểm tra về sớm. [window] là Shift Window đã được resolve sẵn (xem
  /// calculateIsLate ở trên).
  bool calculateEarlyLeave({
    required DateTime checkOutTime,
    required ({DateTime start, DateTime end}) window,
  }) {
    return checkOutTime.isBefore(window.end);
  }

  CompanySettingsModel copyWith({
    String? companyName,
    double? latitude,
    double? longitude,
    double? radius,
    String? dayShiftStart,
    String? dayShiftEnd,
    String? nightShiftStart,
    String? nightShiftEnd,
    int? rotationDays,
    DateTime? rotationStartDate,
  }) {
    return CompanySettingsModel(
      id: id,

      companyName:
      companyName ?? this.companyName,

      latitude:
      latitude ?? this.latitude,

      longitude:
      longitude ?? this.longitude,

      radius:
      radius ?? this.radius,

      dayShiftStart:
      dayShiftStart ?? this.dayShiftStart,

      dayShiftEnd:
      dayShiftEnd ?? this.dayShiftEnd,

      nightShiftStart:
      nightShiftStart ??
          this.nightShiftStart,

      nightShiftEnd:
      nightShiftEnd ??
          this.nightShiftEnd,

      rotationDays:
      rotationDays ?? this.rotationDays,

      rotationStartDate:
      rotationStartDate ??
          this.rotationStartDate,

      updatedAt: DateTime.now(),
    );
  }
}
