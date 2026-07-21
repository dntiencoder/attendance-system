import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/device_activation_repository.dart';
import '../../../core/utils/app_logger.dart';

final deviceActivationRepositoryProvider =
    Provider<DeviceActivationRepository>((ref) => DeviceActivationRepository());

class DeviceActivationState {
  final bool isLoading;
  final String? error;
  final bool success;

  DeviceActivationState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  DeviceActivationState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return DeviceActivationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class DeviceActivationNotifier extends StateNotifier<DeviceActivationState> {
  final DeviceActivationRepository _repo;

  DeviceActivationNotifier(this._repo) : super(DeviceActivationState());

  Future<void> redeemCode(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.redeemCode(code);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e, st) {
      AppLogger.error('DeviceActivationNotifier.redeemCode', e, st);
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

final deviceActivationProvider = StateNotifierProvider.autoDispose<
    DeviceActivationNotifier, DeviceActivationState>(
  (ref) => DeviceActivationNotifier(ref.read(deviceActivationRepositoryProvider)),
);
