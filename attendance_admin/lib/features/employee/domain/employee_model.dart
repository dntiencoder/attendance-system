import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String id;
  final String employeeCode;
  final String name;
  final String email;
  final String role;
  final String shiftGroup;
  final String departmentId; // Thay đổi từ department sang departmentId
  final String phone;
  final String avatarUrl;
  final bool isActive;
  final DateTime? createdAt;

  // FEAT-05: Anti Fraud & Device Security
  final String? trustedDeviceId;
  final String deviceStatus; // none | activation_required | trusted | locked

  EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.email,
    required this.role,
    this.shiftGroup = 'A',
    this.departmentId = '',
    this.phone = '',
    this.avatarUrl = '',
    this.isActive = true,
    this.createdAt,
    this.trustedDeviceId,
    this.deviceStatus = 'none',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'employeeCode': employeeCode,
      'name': name,
      'email': email,
      'role': role,
      'shiftGroup': shiftGroup,
      'departmentId': departmentId, // Lưu departmentId để Mobile có thể tra cứu
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
      departmentId: map['departmentId'] ?? map['department'] ?? '', // Hỗ trợ fallback nếu còn dữ liệu cũ
      phone: map['phone'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      isActive: map['isActive'] ?? true,

      // FEAT-05 — chỉ đọc để hiển thị; KHÔNG thêm vào toFirestore() vì
      // updateEmployee() (sửa thông tin cơ bản) dựng lại EmployeeModel mới mỗi
      // lần lưu mà không mang theo trustedDeviceId/deviceStatus hiện có — nếu
      // toFirestore() serialize 2 field này, mọi lần sửa tên/SĐT nhân viên sẽ
      // vô tình ghi đè (xoá) trustedDeviceId thật. Việc ghi 2 field này chỉ
      // được thực hiện qua DeviceActivationRepository (issueCode/resetDevice),
      // không qua EmployeeRepository.
      trustedDeviceId: map['trustedDeviceId'],
      deviceStatus: map['deviceStatus'] ?? 'none',

      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
