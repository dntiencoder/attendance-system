import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../core/utils/app_logger.dart';
import '../../home/presentation/home_provider.dart';
import '../../attendance/presentation/attendance_provider.dart';
import '../../attendance/presentation/attendance_history_provider.dart';

class AuthState {
  final bool isLoading;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final Ref _ref;

  AuthNotifier(this._repo, this._ref) : super(AuthState());

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      await _repo.login(
        email: email,
        password: password,
      );

      // Các provider dữ liệu theo-tài-khoản không phải autoDispose, nên vẫn
      // giữ dữ liệu của tài khoản trước đó cho tới khi có gì đó chủ động
      // invalidate. Làm ở ĐÂY (ngay sau đăng nhập thành công, không phải lúc
      // đăng xuất) để đảm bảo FirebaseAuth.instance.currentUser đã chắc chắn
      // là tài khoản MỚI trước khi các provider này dựng lại — nếu invalidate
      // lúc đăng xuất, có khoảng trống currentUser == null khiến provider
      // dựng lại "hụt" (thấy chưa đăng nhập, bỏ qua, không tự thử lại) rồi kẹt
      // ở trạng thái rỗng cho tới khi tự kéo-làm-mới thủ công. Cùng pattern
      // đã dùng ở demo_center_screen.dart khi đổi Demo Time.
      _ref.invalidate(homeProvider);
      _ref.invalidate(attendanceProvider);
      _ref.invalidate(attendanceHistoryProvider);

      state = state.copyWith(
        isLoading: false,
      );
    } catch (e, st) {
      AppLogger.error('AuthNotifier.signIn', e, st);
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    }
  }

  Future<void> signOut() async {
    await _repo.logout();
  }
}

final authProvider =
StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(
    AuthRepository(),
    ref,
  ),
);