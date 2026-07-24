import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../layout/main_layout.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/employee/presentation/employee_screen.dart';
import '../features/attendance/presentation/attendance_screen.dart';
import '../features/leave/presentation/leave_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/device/presentation/device_audit_log_screen.dart';
import '../dev/department_seeder.dart'; // Thêm import này

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login', // Bắt đầu ở trang Login cho an toàn
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final isLoginPage = state.uri.path == '/login';

      if (!isLoggedIn && !isLoginPage) return '/login';
      if (isLoggedIn && isLoginPage) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/employees',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: EmployeeScreen()),
          ),
          GoRoute(
            path: '/attendance',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AttendanceScreen()),
          ),
          GoRoute(
            path: '/leave',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LeaveScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
          // FEAT-05: Lịch sử thiết bị — đóng vai trò Activation History.
          GoRoute(
            path: '/device-audit-log',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DeviceAuditLogScreen()),
          ),
          // Route ẩn để seed dữ liệu phòng ban — chỉ có trong debug build,
          // không được đăng ký ở bản production (P1-06).
          if (kDebugMode)
            GoRoute(
              path: '/dev/seed-departments',
              builder: (context, state) => const DepartmentSeederScreen(),
            ),
        ],
      ),
    ],
  );
});
