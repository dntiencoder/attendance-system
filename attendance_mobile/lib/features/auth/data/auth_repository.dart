import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel> login({
    required String employeeCode,
    required String password,
  }) async {
    try {
      if (employeeCode.trim().isEmpty) {
        throw Exception('Vui lòng nhập mã nhân viên');
      }

      if (password.trim().isEmpty) {
        throw Exception('Vui lòng nhập mật khẩu');
      }

      final query = await _db
          .collection('users')
          .where(
        'employeeCode',
        isEqualTo: employeeCode.trim().toUpperCase(),
      )
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Mã nhân viên không tồn tại');
      }

      final data = query.docs.first.data();

      final email = data['email'] as String;

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password.trim(),
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Không thể đăng nhập');
      }

      final userDoc = await _db
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      final user = UserModel.fromFirestore(userDoc);

      if (!user.isActive) {
        await _auth.signOut();
        throw Exception('Tài khoản đã bị khóa');
      }

      if (!user.isEmployee) {
        await _auth.signOut();
        throw Exception(
          'Tài khoản quản trị vui lòng đăng nhập trên web admin',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          throw Exception('Sai mã nhân viên hoặc mật khẩu');

        case 'wrong-password':
          throw Exception('Sai mật khẩu');

        case 'user-not-found':
          throw Exception('Tài khoản không tồn tại');

        default:
          throw Exception('Đăng nhập thất bại');
      }
    }
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    final userDoc = await _db
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!userDoc.exists) {
      await _auth.signOut();
      return null;
    }

    final user = UserModel.fromFirestore(userDoc);

    if (!user.isActive) {
      await _auth.signOut();
      return null;
    }

    if (!user.isEmployee) {
      await _auth.signOut();
      return null;
    }

    return user;
  }

  Future<void> sendResetPasswordEmail(
      String employeeCode,
      ) async {
    final query = await _db
        .collection('users')
        .where(
      'employeeCode',
      isEqualTo: employeeCode.trim().toUpperCase(),
    )
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Mã nhân viên không tồn tại');
    }

    final email =
    query.docs.first.data()['email'] as String;

    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}