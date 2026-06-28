import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String id;
  final String employeeCode;
  final String name;
  final String email;
  final String role;
  final String shiftGroup;
  final String department; // Đổi từ departmentId sang tên phòng ban trực tiếp
  final String phone;
  final String avatarUrl;
  final bool isActive;
  final DateTime? createdAt;

  EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.email,
    required this.role,
    this.shiftGroup = 'A',
    this.department = '',
    this.phone = '',
    this.avatarUrl = '',
    this.isActive = true,
    this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'employeeCode': employeeCode,
      'name': name,
      'email': email,
      'role': role,
      'shiftGroup': shiftGroup,
      'department': department,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory EmployeeModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return EmployeeModel(
      id: doc.id,
      employeeCode: map['employeeCode'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'employee',
      shiftGroup: map['shiftGroup'] ?? 'A',
      department: map['department'] ?? '',
      phone: map['phone'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
