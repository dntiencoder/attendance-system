import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String uid;
  final String employeeCode;
  final String shift;
  final DateTime? attendanceDate;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double latitude;
  final double longitude;
  final double distance;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final double? workHours;
  final bool isLate;
  final bool isEarlyLeave;
  final String status;
  final DateTime? createdAt;

  AttendanceModel({
    required this.id,
    required this.uid,
    required this.employeeCode,
    required this.shift,
    this.attendanceDate,
    this.checkIn,
    this.checkOut,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.distance = 0.0,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.workHours,
    this.isLate = false,
    this.isEarlyLeave = false,
    this.status = 'completed',
    this.createdAt,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      uid: map['uid'] ?? '',
      employeeCode: map['employeeCode'] ?? '',
      shift: map['shift'] ?? 'day',
      attendanceDate: map['attendanceDate'] != null 
          ? (map['attendanceDate'] as Timestamp).toDate()
          : null,
      checkIn: map['checkIn'] != null 
          ? (map['checkIn'] as Timestamp).toDate()
          : null,
      checkOut: map['checkOut'] != null 
          ? (map['checkOut'] as Timestamp).toDate()
          : null,
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      distance: (map['distance'] ?? 0.0).toDouble(),
      checkOutLatitude: (map['checkOutLatitude'] as num?)?.toDouble(),
      checkOutLongitude: (map['checkOutLongitude'] as num?)?.toDouble(),
      workHours: (map['workHours'] as num?)?.toDouble(),
      isLate: map['isLate'] ?? false,
      isEarlyLeave: map['isEarlyLeave'] ?? false,
      status: map['status'] ?? 'completed',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  bool get hasCheckedOut => checkOut != null;

  double get calculatedWorkHours {
    if (workHours != null) return workHours!;
    if (checkIn == null || checkOut == null) return 0;
    return checkOut!.difference(checkIn!).inMinutes / 60;
  }

  String get shiftLabel {
    switch (shift) {
      case 'day': return 'Ca sáng';
      case 'night': return 'Ca đêm';
      default: return shift;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'on_time': return 'Đúng giờ';
      case 'late': return 'Đi muộn';
      case 'early_leave': return 'Về sớm';
      case 'completed': return 'Hoàn thành';
      default: return status;
    }
  }
}
