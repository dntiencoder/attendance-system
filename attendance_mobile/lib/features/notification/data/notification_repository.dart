import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/notification_model.dart';
import '../../../core/utils/app_logger.dart';

class NotificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Thông báo của chính nhân viên đang đăng nhập, mới nhất trước. Chỉ đọc --
  /// firestore.rules chặn create/update/delete từ phía nhân viên (kể cả đánh
  /// dấu đã đọc). Không dùng .orderBy() kèm .where('uid', ...) trên Firestore
  /// (cần composite index chưa khai báo -- xem BUG-015), sort lại bằng code.
  Stream<List<NotificationModel>> getMyNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);

    return _db
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final notifications = <NotificationModel>[];
      for (final doc in snapshot.docs) {
        try {
          notifications.add(NotificationModel.fromFirestore(doc));
        } catch (e, st) {
          AppLogger.error('NotificationRepository.getMyNotifications (doc ${doc.id})', e, st);
        }
      }
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    });
  }
}
