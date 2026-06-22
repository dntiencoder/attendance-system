import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDashboardStats();
});