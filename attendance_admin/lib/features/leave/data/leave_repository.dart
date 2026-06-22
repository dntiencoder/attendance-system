import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/leave_request_model.dart';

class LeaveRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<LeaveRequestModel>> getLeaveRequests() {
    return _db.collection('leave_requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LeaveRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateRequestStatus(String id, String status, String adminNote) async {
    await _db.collection('leave_requests').doc(id).update({
      'status': status,
      'adminNote': adminNote,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
