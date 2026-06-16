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

  const UserModel({
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

  /// Helper
  bool get isAdmin => role == 'admin';

  bool get isEmployee => role == 'employee';

  /// Firestore -> Model
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
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Model -> Firestore
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

  /// Clone object với dữ liệu mới
  UserModel copyWith({
    String? employeeCode,
    String? name,
    String? email,
    String? role,
    String? departmentId,
    String? phone,
    String? avatarUrl,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid,
      employeeCode: employeeCode ?? this.employeeCode,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel('
        'uid: $uid, '
        'employeeCode: $employeeCode, '
        'name: $name, '
        'email: $email, '
        'role: $role'
        ')';
  }
}