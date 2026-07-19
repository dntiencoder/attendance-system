import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/leave_request_model.dart';
import 'leave_provider.dart';
import '../../../core/utils/date_helper.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/custom_button.dart';

class LeaveScreen extends ConsumerWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myLeaveRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nghỉ phép'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => const Center(
          child: Text('Không thể tải danh sách đơn nghỉ phép. Vui lòng thử lại.'),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'Bạn chưa có đơn nghỉ phép nào.\nNhấn "Tạo đơn mới" để bắt đầu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: requests.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => _LeaveRequestCard(request: requests[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateLeaveSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tạo đơn mới'),
      ),
    );
  }

  void _showCreateLeaveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CreateLeaveSheet(),
    );
  }
}

class _LeaveRequestCard extends StatelessWidget {
  final LeaveRequestModel request;

  const _LeaveRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${DateHelper.toDisplayDate(request.startDate)} - ${DateHelper.toDisplayDate(request.endDate)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              _StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${request.totalDays} ngày',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(request.reason, style: const TextStyle(fontSize: 13)),
          if (request.status != 'pending' && request.adminNote.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ghi chú của admin: ${request.adminNote}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    switch (status) {
      case 'approved':
        label = 'Đã duyệt';
        color = AppColors.success;
        break;
      case 'rejected':
        label = 'Từ chối';
        color = AppColors.error;
        break;
      default:
        label = 'Đang chờ';
        color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _CreateLeaveSheet extends ConsumerStatefulWidget {
  const _CreateLeaveSheet();

  @override
  ConsumerState<_CreateLeaveSheet> createState() => _CreateLeaveSheetState();
}

class _CreateLeaveSheetState extends ConsumerState<_CreateLeaveSheet> {
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now),
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null || _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đủ ngày bắt đầu, ngày kết thúc và nhập lý do.')),
      );
      return;
    }

    await ref.read(createLeaveProvider.notifier).submit(
          startDate: _startDate!,
          endDate: _endDate!,
          reason: _reasonController.text.trim(),
        );

    final state = ref.read(createLeaveProvider);
    if (!mounted) return;

    if (state.isSuccess) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi đơn nghỉ phép!'), backgroundColor: AppColors.success),
      );
      ref.read(createLeaveProvider.notifier).reset();
    } else if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createLeaveProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tạo đơn nghỉ phép', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(isStart: true),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_startDate == null ? 'Ngày bắt đầu' : DateHelper.toDisplayDate(_startDate!)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _startDate == null ? null : () => _pickDate(isStart: false),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_endDate == null ? 'Ngày kết thúc' : DateHelper.toDisplayDate(_endDate!)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Lý do nghỉ phép',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomButton(
            text: 'Gửi đơn',
            isLoading: createState.isLoading,
            onPressed: createState.isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
