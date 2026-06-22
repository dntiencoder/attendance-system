import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_repository.dart';
import '../domain/company_settings_model.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

final settingsStreamProvider = StreamProvider<CompanySettingsModel>((ref) {
  return ref.watch(settingsRepositoryProvider).getSettings();
});
