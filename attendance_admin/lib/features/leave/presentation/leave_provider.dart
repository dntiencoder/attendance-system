import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/leave_repository.dart';
import '../domain/leave_request_model.dart';
import '../../notification/data/notification_repository.dart';
import '../../notification/domain/notification_model.dart';

final leaveRepositoryProvider = Provider((ref) => LeaveRepository());
final notificationRepositoryProvider = Provider((ref) => NotificationRepository());

final leaveRequestsStreamProvider = StreamProvider<List<LeaveRequestModel>>((ref) {
  return ref.watch(leaveRepositoryProvider).getLeaveRequests();
});

class LeaveActionNotifier extends StateNotifier<AsyncValue<void>> {
  final LeaveRepository _repository;
  final NotificationRepository _notifRepo;

  LeaveActionNotifier(this._repository, this._notifRepo) : super(const AsyncValue.data(null));

  Future<void> updateStatus(LeaveRequestModel request, String status, {String? adminNote}) async {
    state = const AsyncValue.loading();
    try {
      // 1. Cập nhật trạng thái đơn nghỉ
      await _repository.updateLeaveStatus(request.id, status, adminNote: adminNote);
      
      // 2. Gửi thông báo cho nhân viên
      final bool isApproved = status == 'approved';
      final String title = isApproved ? 'Đơn nghỉ phép đã được duyệt' : 'Đơn nghỉ phép bị từ chối';
      final String body = isApproved 
          ? 'Đơn nghỉ của bạn từ ngày ${request.startDate?.day}/${request.startDate?.month} đã được chấp nhận.'
          : 'Yêu cầu nghỉ phép của bạn không được chấp nhận. Lý do: ${adminNote ?? "Không có"}';

      final notification = NotificationModel(
        id: '',
        uid: request.uid,
        title: title,
        body: body,
        type: isApproved ? 'leave_approved' : 'leave_rejected',
        createdAt: DateTime.now(),
      );

      await _notifRepo.sendNotification(notification);
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final leaveActionProvider = StateNotifierProvider<LeaveActionNotifier, AsyncValue<void>>((ref) {
  return LeaveActionNotifier(
    ref.watch(leaveRepositoryProvider),
    ref.watch(notificationRepositoryProvider),
  );
});
