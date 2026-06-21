import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';
import '../domain/company_settings_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/loading_widget.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _companyNameController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _radiusController;
  late TextEditingController _dayStartController;
  late TextEditingController _dayEndController;
  late TextEditingController _nightStartController;
  late TextEditingController _nightEndController;
  late TextEditingController _rotationDaysController;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _latController = TextEditingController();
    _lngController = TextEditingController();
    _radiusController = TextEditingController();
    _dayStartController = TextEditingController();
    _dayEndController = TextEditingController();
    _nightStartController = TextEditingController();
    _nightEndController = TextEditingController();
    _rotationDaysController = TextEditingController();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    _dayStartController.dispose();
    _dayEndController.dispose();
    _nightStartController.dispose();
    _nightEndController.dispose();
    _rotationDaysController.dispose();
    super.dispose();
  }

  void _updateControllers(CompanySettingsModel settings) {
    _companyNameController.text = settings.companyName;
    _latController.text = settings.latitude.toString();
    _lngController.text = settings.longitude.toString();
    _radiusController.text = settings.radius.toString();
    _dayStartController.text = settings.dayShiftStart;
    _dayEndController.text = settings.dayShiftEnd;
    _nightStartController.text = settings.nightShiftStart;
    _nightEndController.text = settings.nightShiftEnd;
    _rotationDaysController.text = settings.rotationDays.toString();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsStreamProvider);

    return settingsAsync.when(
      loading: () => const LoadingWidget(message: 'Đang tải cấu hình...'),
      error: (err, _) => Center(child: Text('Lỗi: $err')),
      data: (settings) {
        // Cập nhật controller lần đầu hoặc khi có dữ liệu mới
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_companyNameController.text.isEmpty) {
            _updateControllers(settings);
          }
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader('Cấu hình Công ty & GPS', Icons.business_rounded),
                const SizedBox(height: AppSpacing.lg),
                _buildCard([
                  _buildTextField(_companyNameController, 'Tên công ty', Icons.apartment),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_latController, 'Vĩ độ (Latitude)', Icons.location_on)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildTextField(_lngController, 'Kinh độ (Longitude)', Icons.location_on)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(_radiusController, 'Bán kính cho phép (mét)', Icons.radar),
                ]),
                
                const SizedBox(height: AppSpacing.xl),
                _buildHeader('Cấu hình Ca làm việc', Icons.access_time_filled),
                const SizedBox(height: AppSpacing.lg),
                _buildCard([
                  const Text('Ca Ngày (Day Shift)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_dayStartController, 'Bắt đầu', Icons.login)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildTextField(_dayEndController, 'Kết thúc', Icons.logout)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Ca Đêm (Night Shift)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_nightStartController, 'Bắt đầu', Icons.login)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildTextField(_nightEndController, 'Kết thúc', Icons.logout)),
                    ],
                  ),
                ]),

                const SizedBox(height: AppSpacing.xl),
                _buildHeader('Cấu hình Xoay ca', Icons.sync_problem),
                const SizedBox(height: AppSpacing.lg),
                _buildCard([
                  _buildTextField(_rotationDaysController, 'Chu kỳ xoay ca (ngày)', Icons.calendar_month),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Ghi chú: Chu kỳ này dùng để tự động đổi ca giữa Nhóm A và Nhóm B.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                  ),
                ]),

                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _saveSettings(ref),
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu cấu hình'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
    );
  }

  Future<void> _saveSettings(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    final newSettings = CompanySettingsModel(
      companyName: _companyNameController.text,
      latitude: double.parse(_latController.text),
      longitude: double.parse(_lngController.text),
      radius: double.parse(_radiusController.text),
      dayShiftStart: _dayStartController.text,
      dayShiftEnd: _dayEndController.text,
      nightShiftStart: _nightStartController.text,
      nightShiftEnd: _nightEndController.text,
      rotationDays: int.parse(_rotationDaysController.text),
    );

    try {
      await ref.read(settingsRepositoryProvider).updateSettings(newSettings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật cấu hình hệ thống thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
