import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/attendance_model.dart';

class AttendanceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<AttendanceModel>> getAttendanceLogs() {
    return _db.collection('attendance')
        .orderBy('attendanceDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    });
  }
}
