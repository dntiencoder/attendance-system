import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/change_password_page.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/main_shell_screen.dart';
import '../../features/attendance/presentation/attendance_history_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/leave/presentation/leave_screen.dart';
import '../../features/notification/presentation/notification_screen.dart';
import '../../features/dev_tools/presentation/demo_center_screen.dart';
import '../../features/device/presentation/device_activation_screen.dart';
import '../../features/device/data/device_activation_repository.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  // FEAT-05: cache kết quả kiểm tra thiết bị tin cậy theo uid — redirect
  // chạy lại ở MỌI lần điều hướng, nếu không cache sẽ gọi Firestore liên tục.
  // Reset về null khi đăng xuất (user == null). Xem
  // docs/implementation/FEAT_05_IMPLEMENTATION_PLAN.md Phase 13.
  static String? _deviceCheckedForUid;
  static bool _deviceTrustedForCurrentUid = false;

  /// Gọi ngay sau khi redeem Activation Code thành công, để lần redirect kế
  /// tiếp không phải đọc lại Firestore và không bị đẩy ngược lại màn kích
  /// hoạt (dữ liệu Firestore vừa ghi có thể chưa kịp phản ánh qua get() mới).
  static void markCurrentDeviceTrusted() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _deviceCheckedForUid = uid;
    _deviceTrustedForCurrentUid = true;
  }

  static final router = GoRouter(
    initialLocation: '/home',
    navigatorKey: _rootNavigatorKey,
    // Lắng nghe sự thay đổi trạng thái đăng nhập để tự động redirect
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggingIn = state.matchedLocation == '/login';
      final isForgotPassword = state.matchedLocation == '/forgot-password';
      final isDeviceActivation = state.matchedLocation == '/device-activation';

      if (user == null) {
        _deviceCheckedForUid = null;
        if (isLoggingIn || isForgotPassword) return null;
        return '/login';
      }

      if (isForgotPassword) return null;

      // FEAT-05: kiểm tra thiết bị tin cậy — chỉ 1 lần/uid (cache ở trên),
      // không phải mỗi lần điều hướng. Bỏ qua với /forgot-password (đã xử lý
      // ở trên) vì màn đó không cần đăng nhập.
      if (_deviceCheckedForUid != user.uid) {
        final profile = await AuthRepository().getCurrentUserProfile();
        if (profile == null) {
          // Hồ sơ không hợp lệ/đã bị khoá — AuthRepository đã tự signOut(),
          // lần redirect kế tiếp user sẽ là null.
          return '/login';
        }
        _deviceTrustedForCurrentUid = await DeviceActivationRepository()
            .isCurrentDeviceTrusted(trustedDeviceId: profile.trustedDeviceId);
        _deviceCheckedForUid = user.uid;
      }

      if (!_deviceTrustedForCurrentUid) {
        return isDeviceActivation ? null : '/device-activation';
      }

      if (isDeviceActivation || isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/change-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationScreen(),
      ),
      // FEAT-05: hiện khi thiết bị hiện tại chưa khớp trustedDeviceId.
      GoRoute(
        path: '/device-activation',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DeviceActivationScreen(),
      ),
      // Route ẩn để chỉnh giờ demo — chỉ có trong debug build,
      // không được đăng ký ở bản production (BUG-013).
      if (kDebugMode)
        GoRoute(
          path: '/demo-center',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const DemoCenterScreen(),
        ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const AttendanceHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leave',
                builder: (context, state) => const LeaveScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Helper class để GoRouter lắng nghe được Stream từ Firebase
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
