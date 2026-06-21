import 'package:flutter/material.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  // Bộ điều khiển thu thập dữ liệu Form hoạt động thật
  final _officeController = TextEditingController(text: 'Trụ sở chính công ty UMC');
  final _latController = TextEditingController(text: '10.762622');
  final _lngController = TextEditingController(text: '106.660172');
  final _radiusController = TextEditingController(text: '100');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _officeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.fmd_good_rounded, color: Color(0xFFB91C1C)),
            SizedBox(width: 8),
            Text('Thiết Lập Tọa Độ Văn Phòng & Bán Kính Định Vị', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(12), 
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 500, 
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _officeController,
                            validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tên văn phòng' : null,
                            decoration: const InputDecoration(labelText: 'Tên địa điểm', prefixIcon: Icon(Icons.business_rounded, color: Color(0xFFB91C1C)), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _latController,
                            validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập vĩ độ' : null,
                            decoration: const InputDecoration(labelText: 'Tọa độ Vĩ độ (Latitude)', prefixIcon: Icon(Icons.explore_outlined, color: Color(0xFFB91C1C)), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _lngController,
                            validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập kinh độ' : null,
                            decoration: const InputDecoration(labelText: 'Tọa độ Kinh độ (Longitude)', prefixIcon: Icon(Icons.explore_outlined, color: Color(0xFFB91C1C)), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _radiusController,
                            validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập bán kính quét' : null,
                            decoration: const InputDecoration(labelText: 'Bán kính (Mét)', prefixIcon: Icon(Icons.radar_rounded, color: Color(0xFFB91C1C)), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Sau này đắp hàm xử lý Firestore update dữ liệu GPS tại đây
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật cấu hình định vị GPS!')));
                        }
                      }, 
                      icon: const Icon(Icons.cloud_upload_rounded),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB91C1C), 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      label: const Text('Lưu Thay Đổi Cấu Hình GPS'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
