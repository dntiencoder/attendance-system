import 'package:flutter/material.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final List<Map<String, String>> _requests = [
    {'name': 'Lê Văn C', 'reason': 'Xin nghỉ ốm đi khám răng định kỳ', 'range': '09/06 đến 10/06', 'status': 'Chờ xử lý'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.rate_review_rounded, color: Color(0xFFB91C1C)),
            SizedBox(width: 8),
            Text('Phê Duyệt Đơn Xin Nghỉ Phép', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
                    DataColumn(label: Text('Nhân viên', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Lý do xin nghỉ', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Khoảng thời gian', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Quyết định', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _requests.map((req) {
                    final bool isPending = req['status'] == 'Chờ xử lý';
                    return DataRow(cells: [
                      DataCell(Text(req['name']!, style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(req['reason']!)),
                      DataCell(Text(req['range']!)),
                      DataCell(Chip(
                        label: Text(req['status']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: req['status'] == 'Đã duyệt' ? Colors.green : (req['status'] == 'Từ chối' ? Colors.red : Colors.orange))),
                        backgroundColor: req['status'] == 'Đã duyệt' ? const Color(0xFFDCFCE7) : (req['status'] == 'Từ chối' ? const Color(0xFFFEE2E2) : const Color(0xFFFEF9C3)),
                        side: BorderSide.none,
                      )),
                      DataCell(isPending 
                        ? Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle_rounded, color: Colors.green), 
                                onPressed: () { setState(() { req['status'] = 'Đã duyệt'; }); }
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_rounded, color: Colors.red), 
                                onPressed: () { setState(() { req['status'] = 'Từ chối'; }); }
                              ),
                            ],
                          )
                        : const Text('Đã xử lý xong', style: TextStyle(color: Colors.grey, fontSize: 13))),
                    ]);
                  }).toList(),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
