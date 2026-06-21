import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/employee_repository.dart';
import '../domain/employee_model.dart';

final employeeRepositoryProvider = Provider((ref) => EmployeeRepository());

final employeesStreamProvider = StreamProvider<List<EmployeeModel>>((ref) {
  return ref.watch(employeeRepositoryProvider).getEmployees();
});
