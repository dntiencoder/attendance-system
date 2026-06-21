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
  final double checkOutLatitude;
  final double checkOutLongitude;
  final double workHours;
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
    this.checkOutLatitude = 0.0,
    this.checkOutLongitude = 0.0,
    this.workHours = 0.0,
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
      checkOutLatitude: (map['checkOutLatitude'] ?? 0.0).toDouble(),
      checkOutLongitude: (map['checkOutLongitude'] ?? 0.0).toDouble(),
      workHours: (map['workHours'] ?? 0.0).toDouble(),
      isLate: map['isLate'] ?? false,
      isEarlyLeave: map['isEarlyLeave'] ?? false,
      status: map['status'] ?? 'completed',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
