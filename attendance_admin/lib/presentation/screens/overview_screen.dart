import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.dashboard_customize_rounded, color: Color(0xFFB91C1C)),
              SizedBox(width: 8),
              Text('Tổng Quan Hệ Thống Hôm Nay', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 24),
          
          // Đã sửa đổi: Xóa const trước dấu ngoặc vuông để không bị lỗi compile dữ liệu động
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              const StatCard(title: 'Tổng số nhân viên', value: '150', icon: Icons.people_alt_rounded, color: Colors.blue),
              const StatCard(title: 'Đã Check-In', value: '132', icon: Icons.check_circle_rounded, color: Colors.green),
              const StatCard(title: 'Đi muộn', value: '8', icon: Icons.warning_amber_rounded, color: Colors.orange),
              const StatCard(title: 'Đơn phép chờ duyệt', value: '5', icon: Icons.hourglass_top_rounded, color: Color(0xFFB91C1C)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 400,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(12), 
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.insert_chart_rounded, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Khung hiển thị đồ thị thống kê chuyên cần', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}