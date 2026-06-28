import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../auth/domain/user_model.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../home/presentation/home_provider.dart';

class ProfileInfoList extends ConsumerStatefulWidget {
  final UserModel user;
  final String departmentName;

  const ProfileInfoList({
    super.key,
    required this.user,
    required this.departmentName,
  });

  @override
  ConsumerState<ProfileInfoList> createState() => _ProfileInfoListState();
}

class _ProfileInfoListState extends ConsumerState<ProfileInfoList> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showEditPhoneDialog() {
    _phoneController.text = widget.user.phone;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật số điện thoại'),
        content: TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Số điện thoại',
            hintText: 'Nhập số điện thoại mới',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final newPhone = _phoneController.text.trim();
              if (newPhone.isNotEmpty) {
                try {
                  await AuthRepository().updatePhoneNumber(newPhone);
                  
                  // Sau khi update Firestore thành công, gọi refresh homeProvider để cập nhật UI
                  ref.read(homeProvider.notifier).refresh();

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật thành công'), backgroundColor: AppColors.success),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thông tin cá nhân
        _buildSection(
          title: 'Thông tin cá nhân',
          children: [
            _buildRow(
              icon: Icons.badge_outlined,
              label: 'Mã nhân viên',
              value: widget.user.employeeCode,
            ),
            _buildRow(
              icon: Icons.person_outline,
              label: 'Họ và tên',
              value: widget.user.name,
            ),
            _buildRow(
              icon: Icons.mail_outline,
              label: 'Email',
              value: widget.user.email,
            ),
            _buildRow(
              icon: Icons.phone_outlined,
              label: 'Số điện thoại',
              value: widget.user.phone.isNotEmpty ? widget.user.phone : 'Chưa cập nhật',
              isTap: true,
              onTap: _showEditPhoneDialog,
            ),
            _buildRow(
              icon: Icons.business_outlined,
              label: 'Phòng ban',
              value: widget.departmentName.isNotEmpty ? widget.departmentName : widget.user.departmentId,
            ),
            _buildRow(
              icon: Icons.calendar_today_outlined,
              label: 'Ngày vào làm',
              value: '${widget.user.createdAt.day.toString().padLeft(2, '0')}/${widget.user.createdAt.month.toString().padLeft(2, '0')}/${widget.user.createdAt.year}',
              isLast: true,
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Cài đặt
        _buildSection(
          title: 'Cài đặt',
          children: [
            _buildActionRow(
              icon: Icons.lock_outline,
              label: 'Đổi mật khẩu',
              iconBg: AppColors.primary.withValues(alpha: 0.1),
              iconColor: AppColors.primary,
              onTap: () => context.push('/change-password'),
            ),
            _buildActionRow(
              icon: Icons.notifications_none,
              label: 'Thông báo',
              iconBg: AppColors.success.withValues(alpha: 0.1),
              iconColor: AppColors.success,
              isLast: true,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 9, 13, 6),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
                fontSize: 10,
              ),
            ),
          ),
          const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
    bool isTap = false,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isTap ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 14, color: AppColors.primary),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  ),
                  Text(
                    value,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isTap)
              const Icon(
                Icons.chevron_right,
                size: 14,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required Color iconBg,
    required Color iconColor,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
