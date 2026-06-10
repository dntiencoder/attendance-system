import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String uid;
  final String employeeCode;
  final DateTime attendanceDate;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double latitude;
  final double longitude;
  final double distance;
  final bool isLate;
  final String status;
  final DateTime createdAt;

  AttendanceModel({
    required this.id,
    required this.uid,
    required this.employeeCode,
    required this.attendanceDate,
    this.checkIn,
    this.checkOut,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.isLate,
    required this.status,
    required this.createdAt,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      employeeCode: data['employeeCode'] ?? '',
      attendanceDate: (data['attendanceDate'] as Timestamp).toDate(),
      checkIn: data['checkIn'] != null
          ? (data['checkIn'] as Timestamp).toDate()
          : null,
      checkOut: data['checkOut'] != null
          ? (data['checkOut'] as Timestamp).toDate()
          : null,
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      distance: (data['distance'] ?? 0).toDouble(),
      isLate: data['isLate'] ?? false,
      status: data['status'] ?? 'on_time',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'employeeCode': employeeCode,
      'attendanceDate': Timestamp.fromDate(attendanceDate),
      'checkIn': checkIn != null ? Timestamp.fromDate(checkIn!) : null,
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'isLate': isLate,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Tính số giờ làm việc
  double get workHours {
    if (checkIn == null || checkOut == null) return 0;
    return checkOut!.difference(checkIn!).inMinutes / 60;
  }

  // Kiểm tra đã check out chưa
  bool get hasCheckedOut => checkOut != null;

  AttendanceModel copyWith({DateTime? checkOut, bool? isLate, String? status}) {
    return AttendanceModel(
      id: id,
      uid: uid,
      employeeCode: employeeCode,
      attendanceDate: attendanceDate,
      checkIn: checkIn,
      latitude: latitude,
      longitude: longitude,
      distance: distance,
      createdAt: createdAt,
      checkOut: checkOut ?? this.checkOut,
      isLate: isLate ?? this.isLate,
      status: status ?? this.status,
    );
  }
}