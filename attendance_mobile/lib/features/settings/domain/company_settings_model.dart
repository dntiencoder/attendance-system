import 'package:cloud_firestore/cloud_firestore.dart';

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
    // 1. Chuẩn hóa ngày về 00:00:00
    final normalizedStart = DateTime(rotationStartDate.year, rotationStartDate.month, rotationStartDate.day);
    final normalizedToday = DateTime(today.year, today.month, today.day);
    
    // 2. Tính số ngày đã trôi qua
    final daysPassed = normalizedToday.difference(normalizedStart).inDays;
    
    // 3. Logic 2 tuần (14 ngày) đổi 1 lần:
    // rotationIndex: cho biết đang ở khối 14 ngày thứ mấy
    // index 0 (ngày 0-13): Khối 1
    // index 1 (ngày 14-27): Khối 2
    final rotationIndex = (daysPassed / 14).floor();

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

  /// Kiểm tra đi muộn
  bool calculateIsLate({
    required DateTime checkInTime,
    required String shift,
  }) {
    final startTime =
    getShiftStartTime(shift);

    final parts = startTime.split(':');

    final workStart = DateTime(
      checkInTime.year,
      checkInTime.month,
      checkInTime.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    return checkInTime.isAfter(workStart);
  }
  bool calculateEarlyLeave({
    required DateTime checkOutTime,
    required String shift,
  }) {
    final endTime = getShiftEndTime(shift);

    final parts = endTime.split(':');
    final endHour = int.parse(parts[0]);
    final endMinute = int.parse(parts[1]);

    DateTime workEnd = DateTime(
      checkOutTime.year,
      checkOutTime.month,
      checkOutTime.day,
      endHour,
      endMinute,
    );

    if (shift == 'night') {
      // Nếu check-out vào ban ngày (ví dụ 10:00) sau khi ca đêm kết thúc (08:00)
      // thì chắc chắn không phải về sớm.
      if (checkOutTime.hour >= 8 && checkOutTime.hour < 18) {
        return false;
      }

      // Nếu check-out vào buổi tối (ví dụ 21:00) mà ca đêm kết thúc vào sáng hôm sau (08:00)
      // thì workEnd phải là ngày hôm sau.
      if (checkOutTime.hour >= 12 && endHour < 12) {
        workEnd = workEnd.add(const Duration(days: 1));
      }
    }

    return checkOutTime.isBefore(workEnd);
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
