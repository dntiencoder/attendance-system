import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/department/presentation/department_provider.dart'; // Sửa import này
import '../features/department/data/department_repository.dart';

class DepartmentSeederScreen extends ConsumerWidget {
  const DepartmentSeederScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = {
      'dept_fac': 'Phòng Cơ sở vật chất (FAC Dept)',
      'dept_ga': 'Phòng Hành chính – Nhân sự (GA Dept)',
      'dept_pd': 'Phòng PD (PD Dept)',
      'dept_te': 'Phòng Kỹ thuật (TE Dept)',
      'dept_pe': 'Phòng Kỹ thuật sản xuất (PE Dept)',
      'dept_dx': 'Phòng Chuyển đổi số (DX Dept)',
      'dept_pmc': 'Phòng PMC (PMC Dept)',
      'dept_pur1': 'Phòng Mua hàng 1 (PUR Dept 1)',
      'dept_pur2': 'Phòng Mua hàng 2 (PUR Dept 2)',
      'dept_sales': 'Phòng Kinh doanh (Sales Dept)',
      'dept_acc': 'Phòng Kế toán (ACC Dept)',
      'dept_qa': 'Phòng Đảm bảo chất lượng (QA Dept)',
      'dept_ia': 'Bộ phận Kiểm toán nội bộ (Internal Audit)',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Department Seeder')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await ref.read(departmentRepositoryProvider).seedDepartments(departments);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Departments seeded successfully!')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          child: const Text('Seed Departments'),
        ),
      ),
    );
  }
}
