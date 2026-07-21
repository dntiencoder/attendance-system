import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/device_audit_log_repository.dart';
import '../domain/device_audit_log_model.dart';

final deviceAuditLogRepositoryProvider =
    Provider<DeviceAuditLogRepository>((ref) => DeviceAuditLogRepository());

final deviceAuditLogProvider =
    StreamProvider.family<List<DeviceAuditLogModel>, String>((ref, uid) {
  return ref.watch(deviceAuditLogRepositoryProvider).getLogsForUser(uid);
});
