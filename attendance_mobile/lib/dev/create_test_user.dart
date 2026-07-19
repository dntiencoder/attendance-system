// ignore_for_file: avoid_print
// Script dev chạy tay qua console -- print() là output chủ đích, không phải
// log lỗi cần thay bằng logging framework.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTestUser {
  // Giá trị mặc định chỉ là placeholder. Truyền email/password thật qua
  // --dart-define khi chạy, không hardcode giá trị thật vào source:
  //   flutter run -t lib/main_dev.dart \
  //     --dart-define=TEST_USER_EMAIL=... --dart-define=TEST_USER_PASSWORD=...
  static const _email = String.fromEnvironment(
    'TEST_USER_EMAIL',
    defaultValue: 'test.employee@example.com',
  );
  static const _password = String.fromEnvironment(
    'TEST_USER_PASSWORD',
    defaultValue: 'ChangeMe123!',
  );

  static Future<void> createEmployee() async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'employeeCode': 'EMP001',
        'name': 'Danh Nhật Tiến',
        'email': _email,
        'role': 'employee',

        // mới
        'shiftGroup': 'A',

        'departmentId': '',
        'phone': '',
        'avatarUrl': '',
        'isActive': true,

        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      print('✅ Test user created');
      print('UID: $uid');
    } on FirebaseAuthException catch (e) {
      print('❌ ${e.code}');
    } catch (e) {
      print('❌ $e');
    }
  }
}