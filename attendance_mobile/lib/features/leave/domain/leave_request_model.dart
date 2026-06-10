import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRequestModel {
  final String id;
  final String uid;
  final String employeeCode;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status; // pending | approved | rejected
  final String adminNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveRequestModel({
    required this.id,
    required this.uid,
    required this.employeeCode,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = 'pending',
    this.adminNote = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaveRequestModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      employeeCode: data['employeeCode'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'pending',
      adminNote: data['adminNote'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'employeeCode': employeeCode,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'reason': reason,
      'status': status,
      'adminNote': adminNote,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Tính số ngày nghỉ
  int get totalDays => endDate.difference(startDate).inDays + 1;

  // Kiểm tra trạng thái
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  LeaveRequestModel copyWith({
    String? status,
    String? adminNote,
    DateTime? updatedAt,
  }) {
    return LeaveRequestModel(
      id: id,
      uid: uid,
      employeeCode: employeeCode,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      createdAt: createdAt,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}