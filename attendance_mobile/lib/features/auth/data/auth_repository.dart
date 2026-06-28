import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.trim().isEmpty) {
        throw Exception('Vui lòng nhập email');
      }

      if (password.trim().isEmpty) {
        throw Exception('Vui lòng nhập mật khẩu');
      }

      final credential =
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
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
          throw Exception('Sai email hoặc mật khẩu');

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
    String email,
  ) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> reauthenticate(String currentPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');
    final email = user.email;
    if (email == null) throw Exception('Email không tìm thấy');

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');
    await user.updatePassword(newPassword);
  }

  Future<void> updatePhoneNumber(String phone) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');
    await _db.collection('users').doc(user.uid).update({'phone': phone});
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}