import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notification_repository.dart';

final notificationRepositoryProvider = Provider((ref) => NotificationRepository());

final myNotificationsProvider = StreamProvider((ref) {
  return ref.watch(notificationRepositoryProvider).getMyNotifications();
});
