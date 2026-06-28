import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/department_repository.dart';
import '../domain/department_model.dart';

final departmentRepositoryProvider = Provider((ref) => DepartmentRepository());

final departmentsStreamProvider = StreamProvider<List<DepartmentModel>>((ref) {
  return ref.watch(departmentRepositoryProvider).getDepartments();
});
