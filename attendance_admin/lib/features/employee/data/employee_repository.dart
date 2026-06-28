import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../domain/employee_model.dart';

class EmployeeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Lấy danh sách nhân viên realtime
  Stream<List<EmployeeModel>> getEmployees() {
    return _db.collection('users')
        .where('role', isEqualTo: 'employee') // Mobile uses 'employee'
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EmployeeModel.fromFirestore(doc))
          .toList();
    });
  }

  // Thêm nhân viên mới (Auth + Firestore)
  Future<void> addEmployee(EmployeeModel employee, String password) async {
    // 1. Tạo một Secondary App để tạo User mà không bị logout Admin hiện tại
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: Firebase.app().options,
    );

    try {
      // 2. Tạo tài khoản trong Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
        email: employee.email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // 3. Lưu thông tin vào Firestore với ID trùng với UID của Auth
      final employeeData = employee.toFirestore();
      await _db.collection('users').doc(uid).set(employeeData);

    } finally {
      // 4. Luôn xóa secondary app sau khi dùng xong để giải phóng tài nguyên
      await secondaryApp.delete();
    }
  }

  // Cập nhật nhân viên
  Future<void> updateEmployee(EmployeeModel employee) async {
    await _db.collection('users').doc(employee.id).update(employee.toFirestore());
  }

  // Xóa nhân viên
  Future<void> deleteEmployee(String id) async {
    await _db.collection('users').doc(id).delete();
  }

  // Cập nhật trạng thái hoạt động
  Future<void> toggleStatus(String id, bool currentStatus) async {
    await _db.collection('users').doc(id).update({'isActive': !currentStatus});
  }
}
