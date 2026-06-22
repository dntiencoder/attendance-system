import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/department_model.dart';

class DepartmentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<DepartmentModel>> getDepartments() {
    return _db.collection('departments')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DepartmentModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addDepartment(DepartmentModel department) async {
    await _db.collection('departments').add(department.toFirestore());
  }
}
