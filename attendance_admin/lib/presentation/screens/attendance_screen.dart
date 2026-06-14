import 'package:flutter/material.dart';

class AttendanceLogScreen extends StatelessWidget {
  const AttendanceLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Lịch sử chấm công', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang xuất tệp báo cáo định dạng PDF...'))); }, 
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  label: const Text('Xuất PDF'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang xuất dữ liệu ra file bảng tính Excel (.xlsx)...'))); }, 
                  icon: const Icon(Icons.download_for_offline, color: Colors.green),
                  label: const Text('Xuất Excel (.xlsx)'),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            color: Colors.white,
            child: ListView(
              children: [
                DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                  columns: const [
                    DataColumn(label: Text('Ngày chấm', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nhân viên', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check-In', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check-Out', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('08/06/2026')),
                      DataCell(Text('Nguyễn Văn A')),
                      DataCell(Text('07:55 AM')),
                      DataCell(Text('17:05 PM')),
                      DataCell(Chip(label: Text('Đúng giờ'), backgroundColor: Color(0xFFDCFCE7), side: BorderSide.none)),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}