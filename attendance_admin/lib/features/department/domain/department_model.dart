import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  final String id;
  final String name;
  final String managerUid;
  final DateTime? createdAt;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.managerUid,
    this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'managerUid': managerUid,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory DepartmentModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return DepartmentModel(
      id: doc.id,
      name: map['name'] ?? '',
      managerUid: map['managerUid'] ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
