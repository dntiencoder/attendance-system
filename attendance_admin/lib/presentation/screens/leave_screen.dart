import 'package:flutter/material.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  // Quản lý danh sách đơn nghỉ phép và tương tác thay đổi trạng thái trực tiếp khi Admin bấm nút
  final List<Map<String, String>> _requests = [
    {'name': 'Lê Văn C', 'reason': 'Xin nghỉ ốm đi khám răng định kỳ', 'range': '09/06 đến 10/06', 'status': 'Chờ xử lý'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phê Duyệt Đơn Xin Nghỉ Phép', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            color: Colors.white,
            child: ListView(
              children: [
                DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                  columns: const [
                    DataColumn(label: Text('Nhân viên', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Lý do xin nghỉ', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Khoảng thời gian', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Thao tác duyệt', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _requests.map((req) {
                    final bool isPending = req['status'] == 'Chờ xử lý';
                    return DataRow(cells: [
                      DataCell(Text(req['name']!)),
                      DataCell(Text(req['reason']!)),
                      DataCell(Text(req['range']!)),
                      DataCell(Chip(
                        label: Text(req['status']!),
                        backgroundColor: req['status'] == 'Đã duyệt' ? const Color(0xFFDCFCE7) : (req['status'] == 'Từ chối' ? const Color(0xFFFEE2E2) : const Color(0xFFFEF9C3)),
                        side: BorderSide.none,
                      )),
                      DataCell(isPending 
                        ? Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() { req['status'] = 'Đã duyệt'; });
                                  // TODO: Cập nhật Firebase document field 'status' sang 'Approved'
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: const Text('Duyệt'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() { req['status'] = 'Từ chối'; });
                                  // TODO: Cập nhật Firebase field 'status' sang 'Rejected'
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                child: const Text('Từ chối'),
                              ),
                            ],
                          )
                        : const Text('Đã thực hiện xong', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
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