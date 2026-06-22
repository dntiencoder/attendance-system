import 'package:cloud_firestore/cloud_firestore.dart';

class CompanySettingsModel {
  final String companyName;
  final double latitude;
  final double longitude;
  final double radius;
  final String dayShiftStart;
  final String dayShiftEnd;
  final String nightShiftStart;
  final String nightShiftEnd;
  final int rotationDays;
  final DateTime? rotationStartDate;
  final DateTime? updatedAt;

  CompanySettingsModel({
    required this.companyName,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.dayShiftStart,
    required this.dayShiftEnd,
    required this.nightShiftStart,
    required this.nightShiftEnd,
    required this.rotationDays,
    this.rotationStartDate,
    this.updatedAt,
  });

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
      'rotationStartDate': rotationStartDate != null ? Timestamp.fromDate(rotationStartDate!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory CompanySettingsModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return CompanySettingsModel(
      companyName: map['companyName'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      radius: (map['radius'] ?? 0.0).toDouble(),
      dayShiftStart: map['dayShiftStart'] ?? '08:00',
      dayShiftEnd: map['dayShiftEnd'] ?? '20:00',
      nightShiftStart: map['nightShiftStart'] ?? '20:00',
      nightShiftEnd: map['nightShiftEnd'] ?? '08:00',
      rotationDays: map['rotationDays'] ?? 7,
      rotationStartDate: map['rotationStartDate'] != null 
          ? (map['rotationStartDate'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
