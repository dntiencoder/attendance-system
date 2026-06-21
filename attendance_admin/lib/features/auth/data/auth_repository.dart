import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_config.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Sau khi đăng nhập Auth thành công, bắt buộc kiểm tra role trong Firestore
      final userDoc = await _db
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('Tài khoản không tồn tại trong hệ thống');
      }

      final data = userDoc.data();
      final role = data?['role'] ?? '';
      
      // Chấp nhận cả 'admin' (hardcoded cũ) và AppConfig.roleAdmin cho linh hoạt
      if (role != 'admin' && role != AppConfig.roleAdmin) {
        await _auth.signOut();
        throw Exception('Bạn không có quyền truy cập quản trị');
      }

      final isActive = data?['isActive'] ?? false;
      if (!isActive) {
        await _auth.signOut();
        throw Exception('Tài khoản đã bị vô hiệu hóa');
      }
      
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Email hoặc mật khẩu không đúng');
        case 'user-disabled':
          throw Exception('Tài khoản đã bị vô hiệu hóa');
        case 'too-many-requests':
          throw Exception('Quá nhiều lần thử. Vui lòng thử lại sau');
        default:
          throw Exception('Đăng nhập thất bại: ${e.message}');
      }
    } catch (e) {
      // Bắt các lỗi Exception do chúng ta chủ động throw ở trên
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
