import 'package:flutter/material.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final _officeController = TextEditingController(text: 'Trụ sở chính công ty');
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
        const Text('Thiết Lập Tọa Độ Văn Phòng & Bán Kính Định Vị', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 500, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _officeController,
                            validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng điền tên văn phòng' : null,
                            decoration: const InputDecoration(labelText: 'Tên địa điểm văn phòng', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _latController,
                            validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng điền vĩ độ GPS' : null,
                            decoration: const InputDecoration(labelText: 'Tọa độ Vĩ độ (Latitude)', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _lngController,
                            validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng điền kinh độ GPS' : null,
                            decoration: const InputDecoration(labelText: 'Tọa độ Kinh độ (Longitude)', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _radiusController,
                            validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng điền bán kính quét' : null,
                            decoration: const InputDecoration(labelText: 'Bán kính cho phép chấm công', border: OutlineInputBorder(), suffixText: 'Mét'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // TODO: Đẩy 4 chuỗi dữ liệu text này lưu đè lên document 'company_settings/main_config' của Cloud Firestore
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật cấu hình GPS hệ thống!')));
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30)),
                          child: const Text('Lưu Thay Đổi Cấu Hình GPS'),
                        ),
                      ],
                    )
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