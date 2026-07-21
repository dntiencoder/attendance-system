import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/device_activation_repository.dart';

final deviceActivationRepositoryProvider =
    Provider<DeviceActivationRepository>((ref) => DeviceActivationRepository());
