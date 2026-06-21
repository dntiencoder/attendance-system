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
            Row(
              children: const [
                Icon(Icons.assignment_turned_in_rounded, color: Color(0xFFB91C1C)),
                SizedBox(width: 8),
                Text('Nhật Ký Chấm Công Toàn Cầu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 18),
                  label: const Text('Xuất PDF', style: TextStyle(color: Color(0xFF1E293B))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.grid_on_rounded, color: Colors.green, size: 18),
                  label: const Text('Xuất Excel', style: TextStyle(color: Color(0xFF1E293B))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: ListView(
              children: [
                DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
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
                      DataCell(Text('Nguyễn Văn A', style: TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text('07:55 AM')),
                      DataCell(Text('17:05 PM')),
                      DataCell(Chip(
                        label: Text('Đúng giờ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)), 
                        backgroundColor: Color(0xFFDCFCE7), 
                        side: BorderSide.none
                      )),
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