import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'gps_service.dart';

// Provider cho GpsService
final gpsServiceProvider = Provider<GpsService>((ref) => GpsService());

// State của GPS
class GpsState {
  final Position? position;
  final bool isLoading;
  final String? error;

  GpsState({
    this.position,
    this.isLoading = false,
    this.error,
  });

  GpsState copyWith({
    Position? position,
    bool? isLoading,
    String? error,
  }) {
    return GpsState(
      position: position ?? this.position,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier
class GpsNotifier extends StateNotifier<GpsState> {
  final GpsService _gpsService;

  GpsNotifier(this._gpsService) : super(GpsState());

  Future<void> fetchCurrentPosition() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final position = await _gpsService.getCurrentPosition();
      state = state.copyWith(position: position, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final gpsProvider = StateNotifierProvider<GpsNotifier, GpsState>(
      (ref) => GpsNotifier(ref.read(gpsServiceProvider)),
);