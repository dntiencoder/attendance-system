import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Sau này bọc bằng StreamBuilder lắng nghe Firestore để đếm độ dài danh sách (snapshot.data.docs.length)
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng Quan Hệ Thống Hôm Nay', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              StatCard(title: 'Tổng số nhân viên', value: '150', icon: Icons.people, color: Colors.blue),
              StatCard(title: 'Đã Check-In', value: '132', icon: Icons.check_circle, color: Colors.green),
              StatCard(title: 'Đi muộn', value: '8', icon: Icons.warning, color: Colors.orange),
              StatCard(title: 'Đơn phép chờ duyệt', value: '5', icon: Icons.pending, color: Colors.red),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            height: 400,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)),
            child: const Center(
              child: Text('Khung hiển thị đồ thị thống kê chuyên cần', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          )
        ],
      ),
    );
  }
}
    