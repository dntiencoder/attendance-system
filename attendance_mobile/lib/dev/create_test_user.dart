import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTestUser {
  static Future<void> createEmployee() async {
    final credential =
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: 'danhnhattien284@gmail.com',
      password: '123456',
    );

    final uid = credential.user!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
      'employeeCode': 'EMP001',
      'name': 'Danh Nhật Tiến',
      'email': 'danhnhattien284@gmail.com',
      'role': 'employee',
      'departmentId': '',
      'phone': '',
      'avatarUrl': '',
      'isActive': true,
      'createdAt': Timestamp.now(),
    });
  }
}