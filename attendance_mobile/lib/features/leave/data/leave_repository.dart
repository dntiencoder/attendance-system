import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/leave_request_model.dart';
import '../../../core/utils/app_logger.dart';

class LeaveRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Đơn nghỉ phép của chính nhân viên đang đăng nhập, mới nhất trước --
  /// khớp firestore.rules (chỉ đọc được đơn có uid == chính mình).
  Stream<List<LeaveRequestModel>> getMyLeaveRequests() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);

    // Không dùng .orderBy('createdAt') ở đây -- kết hợp với .where('uid', ...)
    // sẽ cần 1 composite index mà firestore.indexes.json chưa khai báo cho
    // leave_requests (khác attendance, đã có sẵn), khiến toàn bộ stream lỗi
    // failed-precondition ngay từ đầu. Sort lại bằng code sau khi tải, giống
    // pattern đã dùng ở attendance_history_provider.dart.
    return _db
        .collection('leave_requests')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final requests = <LeaveRequestModel>[];
      for (final doc in snapshot.docs) {
        try {
          requests.add(LeaveRequestModel.fromFirestore(doc));
        } catch (e, st) {
          AppLogger.error('LeaveRepository.getMyLeaveRequests (doc ${doc.id})', e, st);
        }
      }
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  /// Tạo đơn nghỉ phép mới cho chính nhân viên đang đăng nhập. firestore.rules
  /// chỉ cho phép create (không cho update/delete từ phía nhân viên) -- đơn
  /// đã gửi không tự sửa/huỷ được, chỉ admin duyệt/từ chối.
  Future<void> createLeaveRequest({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    if (endDate.isBefore(startDate)) {
      throw Exception('Ngày kết thúc phải sau hoặc bằng ngày bắt đầu');
    }

    final userDoc = await _db.collection('users').doc(user.uid).get();
    final employeeCode = (userDoc.data()?['employeeCode'] as String?) ?? '';

    final now = DateTime.now();
    final docRef = _db.collection('leave_requests').doc();

    await docRef.set({
      'uid': user.uid,
      'employeeCode': employeeCode,
      'startDate': Timestamp.fromDate(DateTime(startDate.year, startDate.month, startDate.day)),
      'endDate': Timestamp.fromDate(DateTime(endDate.year, endDate.month, endDate.day)),
      'reason': reason,
      'status': 'pending',
      'adminNote': '',
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }
}
