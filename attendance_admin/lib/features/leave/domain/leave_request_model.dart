import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRequestModel {
  final String id;
  final String uid;
  final String employeeCode;
  final DateTime? startDate;
  final DateTime? endDate;
  final String reason;
  final String status;
  final String adminNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeaveRequestModel({
    required this.id,
    required this.uid,
    required this.employeeCode,
    this.startDate,
    this.endDate,
    this.reason = '',
    this.status = 'pending',
    this.adminNote = '',
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'status': status,
      'adminNote': adminNote,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory LeaveRequestModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return LeaveRequestModel(
      id: doc.id,
      uid: map['uid'] ?? '',
      employeeCode: map['employeeCode'] ?? '',
      startDate: map['startDate'] != null 
          ? (map['startDate'] as Timestamp).toDate()
          : null,
      endDate: map['endDate'] != null 
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
      adminNote: map['adminNote'] ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Tính số ngày nghỉ
  int get totalDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  // Kiểm tra trạng thái
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
