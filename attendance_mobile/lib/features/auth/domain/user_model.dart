import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String employeeCode;
  final String name;
  final String email;
  final String role;
  final String departmentId;
  final String phone;
  final String avatarUrl;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.employeeCode,
    required this.name,
    required this.email,
    required this.role,
    this.departmentId = '',
    this.phone = '',
    this.avatarUrl = '',
    this.isActive = true,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      employeeCode: data['employeeCode'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'employee',
      departmentId: data['departmentId'] ?? '',
      phone: data['phone'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employeeCode': employeeCode,
      'name': name,
      'email': email,
      'role': role,
      'departmentId': departmentId,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Tiện dụng khi cần update 1 field
  UserModel copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    String? departmentId,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid,
      employeeCode: employeeCode,
      email: email,
      role: role,
      createdAt: createdAt,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      departmentId: departmentId ?? this.departmentId,
      isActive: isActive ?? this.isActive,
    );
  }
}