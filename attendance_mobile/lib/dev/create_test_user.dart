import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTestUser {
  static Future<void> createEmployee() async {
    try {
      final credential = await FirebaseAuth.instance
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