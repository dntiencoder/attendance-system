import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendNotification(NotificationModel notification) async {
    await _db.collection('notifications').add(notification.toFirestore());
  }
}
