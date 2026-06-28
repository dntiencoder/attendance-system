import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/department_model.dart';

class DepartmentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<DepartmentModel>> getDepartments() {
    return _db.collection('departments')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DepartmentModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> seedDepartments(Map<String, String> departments) async {
    final batch = _db.batch();
    for (var entry in departments.entries) {
      batch.set(_db.collection('departments').doc(entry.key), {
        'name': entry.value,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
