import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/leave_repository.dart';
import '../../../core/utils/app_logger.dart';

final leaveRepositoryProvider = Provider((ref) => LeaveRepository());

final myLeaveRequestsProvider = StreamProvider((ref) {
  return ref.watch(leaveRepositoryProvider).getMyLeaveRequests();
});

class CreateLeaveState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const CreateLeaveState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  CreateLeaveState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return CreateLeaveState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? false,
    );
  }
}

class CreateLeaveNotifier extends StateNotifier<CreateLeaveState> {
  final LeaveRepository _repository;

  CreateLeaveNotifier(this._repository) : super(const CreateLeaveState());

  Future<void> submit({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _repository.createLeaveRequest(
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e, st) {
      AppLogger.error('CreateLeaveNotifier.submit', e, st);
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void reset() => state = const CreateLeaveState();
}

final createLeaveProvider =
    StateNotifierProvider.autoDispose<CreateLeaveNotifier, CreateLeaveState>((ref) {
  return CreateLeaveNotifier(ref.watch(leaveRepositoryProvider));
});
