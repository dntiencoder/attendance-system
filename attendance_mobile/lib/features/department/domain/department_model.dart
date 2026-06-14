import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  final String id;
  final String name;
  final String managerUid;
  final DateTime createdAt;

  DepartmentModel({
    required this.id,
    required this.name,
    this.managerUid = '',
    required this.createdAt,
  });

  factory DepartmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DepartmentModel(
      id: doc.id,
      name: data['name'] ?? '',
      managerUid: data['managerUid'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'managerUid': managerUid,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  DepartmentModel copyWith({String? name, String? managerUid}) {
    return DepartmentModel(
      id: id,
      createdAt: createdAt,
      name: name ?? this.name,
      managerUid: managerUid ?? this.managerUid,
    );
  }
}