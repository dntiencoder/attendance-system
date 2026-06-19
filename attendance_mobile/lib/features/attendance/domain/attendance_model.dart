import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;

  final String uid;
  final String employeeCode;

  // Ca làm việc
  final String shift; // day | night

  final DateTime attendanceDate;

  final DateTime? checkIn;
  final DateTime? checkOut;

  // GPS Check In
  final double latitude;
  final double longitude;
  final double distance;

  // GPS Check Out
  final double? checkOutLatitude;
  final double? checkOutLongitude;

  // Số giờ làm
  final double? workHours;

  final bool isLate;

  /// on_time | late | absent
  final String status;

  final DateTime createdAt;

  const AttendanceModel({
    required this.id,
    required this.uid,
    required this.employeeCode,
    required this.shift,
    required this.attendanceDate,
    this.checkIn,
    this.checkOut,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.workHours,
    required this.isLate,
    required this.status,
    required this.createdAt,
  });

  factory AttendanceModel.fromFirestore(
      DocumentSnapshot doc,
      ) {
    final data =
    doc.data() as Map<String, dynamic>;

    return AttendanceModel(
      id: doc.id,

      uid: data['uid'] ?? '',

      employeeCode:
      data['employeeCode'] ?? '',

      shift: data['shift'] ?? '',

      attendanceDate:
      (data['attendanceDate']
      as Timestamp)
          .toDate(),

      checkIn:
      data['checkIn'] != null
          ? (data['checkIn']
      as Timestamp)
          .toDate()
          : null,

      checkOut:
      data['checkOut'] != null
          ? (data['checkOut']
      as Timestamp)
          .toDate()
          : null,

      latitude:
      (data['latitude'] ?? 0)
          .toDouble(),

      longitude:
      (data['longitude'] ?? 0)
          .toDouble(),

      distance:
      (data['distance'] ?? 0)
          .toDouble(),

      checkOutLatitude:
      (data['checkOutLatitude']
      as num?)
          ?.toDouble(),

      checkOutLongitude:
      (data['checkOutLongitude']
      as num?)
          ?.toDouble(),

      workHours:
      (data['workHours'] as num?)
          ?.toDouble(),

      isLate:
      data['isLate'] ?? false,

      status:
      data['status'] ?? 'on_time',

      createdAt:
      (data['createdAt']
      as Timestamp)
          .toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,

      'employeeCode':
      employeeCode,

      'shift': shift,

      'attendanceDate':
      Timestamp.fromDate(
        attendanceDate,
      ),

      'checkIn':
      checkIn != null
          ? Timestamp.fromDate(
        checkIn!,
      )
          : null,

      'checkOut':
      checkOut != null
          ? Timestamp.fromDate(
        checkOut!,
      )
          : null,

      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,

      'checkOutLatitude':
      checkOutLatitude,

      'checkOutLongitude':
      checkOutLongitude,

      'workHours': workHours,

      'isLate': isLate,

      'status': status,

      'createdAt':
      Timestamp.fromDate(
        createdAt,
      ),
    };
  }

  /// Nếu Firestore chưa lưu workHours
  double get calculatedWorkHours {
    if (workHours != null) {
      return workHours!;
    }

    if (checkIn == null ||
        checkOut == null) {
      return 0;
    }

    return checkOut!
        .difference(checkIn!)
        .inMinutes /
        60;
  }

  bool get hasCheckedOut =>
      checkOut != null;

  bool get isDayShift =>
      shift == 'day';

  bool get isNightShift =>
      shift == 'night';

  String get shiftLabel {
    switch (shift) {
      case 'day':
        return 'Ca ngày';

      case 'night':
        return 'Ca đêm';

      default:
        return '';
    }
  }

  AttendanceModel copyWith({
    DateTime? checkOut,
    double? checkOutLatitude,
    double? checkOutLongitude,
    double? workHours,
    bool? isLate,
    String? status,
    String? shift,
  }) {
    return AttendanceModel(
      id: id,

      uid: uid,

      employeeCode:
      employeeCode,

      shift: shift ?? this.shift,

      attendanceDate:
      attendanceDate,

      checkIn: checkIn,

      checkOut:
      checkOut ?? this.checkOut,

      latitude: latitude,
      longitude: longitude,
      distance: distance,

      checkOutLatitude:
      checkOutLatitude ??
          this.checkOutLatitude,

      checkOutLongitude:
      checkOutLongitude ??
          this.checkOutLongitude,

      workHours:
      workHours ?? this.workHours,

      isLate:
      isLate ?? this.isLate,

      status:
      status ?? this.status,

      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'AttendanceModel('
        'employeeCode: $employeeCode, '
        'shift: $shift, '
        'status: $status'
        ')';
  }
}