import 'package:cloud_firestore/cloud_firestore.dart';

class CompanySettingsModel {
  final String id;
  final String companyName;
  final double latitude;
  final double longitude;
  final double radius;
  final String workStartTime; // "08:00"
  final String workEndTime;   // "17:00"
  final DateTime updatedAt;

  CompanySettingsModel({
    required this.id,
    required this.companyName,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.workStartTime,
    required this.workEndTime,
    required this.updatedAt,
  });

  factory CompanySettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CompanySettingsModel(
      id: doc.id,
      companyName: data['companyName'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      radius: (data['radius'] ?? 100).toDouble(),
      workStartTime: data['workStartTime'] ?? '08:00',
      workEndTime: data['workEndTime'] ?? '17:00',
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'companyName': companyName,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'workStartTime': workStartTime,
      'workEndTime': workEndTime,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Tính isLate dựa vào giờ check in
  bool calculateIsLate(DateTime checkInTime) {
    final parts = workStartTime.split(':');
    final workStart = DateTime(
      checkInTime.year,
      checkInTime.month,
      checkInTime.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    return checkInTime.isAfter(workStart);
  }

  CompanySettingsModel copyWith({
    String? companyName,
    double? latitude,
    double? longitude,
    double? radius,
    String? workStartTime,
    String? workEndTime,
  }) {
    return CompanySettingsModel(
      id: id,
      updatedAt: DateTime.now(),
      companyName: companyName ?? this.companyName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
    );
  }
}