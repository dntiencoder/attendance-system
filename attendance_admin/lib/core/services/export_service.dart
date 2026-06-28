import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/attendance/domain/attendance_model.dart';
import '../utils/date_helper.dart';

class ExportService {
  static Future<void> exportToExcel(List<AttendanceModel> logs) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // 1. Định nghĩa Style cho Header (Màu đỏ UMC, chữ trắng, in đậm)
    final headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#B91C1C'),
      fontColorHex: ExcelColor.white,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      fontFamily: getFontFamily(FontFamily.Arial),
    );

    // 2. Định nghĩa Style cho Dòng dữ liệu (Căn giữa, viền mỏng)
    final dataStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      fontFamily: getFontFamily(FontFamily.Arial),
    );

    // 3. Header Title
    final headers = ['Ngày', 'Mã NV', 'Ca', 'Giờ vào', 'Giờ ra', 'Giờ làm', 'Khoảng cách', 'Trạng thái'];
    for (var i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // 4. Data Rows
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i];
      final rowIndex = i + 1;

      // Đổ dữ liệu vào từng ô
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = TextCellValue(log.attendanceDate != null ? DateHelper.toDisplayDate(log.attendanceDate!) : '-')
        ..cellStyle = dataStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = TextCellValue(log.employeeCode)
        ..cellStyle = dataStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = TextCellValue(log.shift == 'day' ? 'Sáng' : 'Đêm')
        ..cellStyle = dataStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        ..value = TextCellValue(log.checkIn != null ? DateHelper.toTimeString(log.checkIn!) : '-')
        ..cellStyle = dataStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        ..value = TextCellValue(log.checkOut != null ? DateHelper.toTimeString(log.checkOut!) : '-')
        ..cellStyle = dataStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
        ..value = TextCellValue(log.hasCheckedOut ? '${log.calculatedWorkHours.toStringAsFixed(1)}h' : '-')
        ..cellStyle = dataStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
        ..value = TextCellValue('${log.distance.round()}m')
        ..cellStyle = dataStyle;

      // Logic riêng cho cột Trạng thái (Màu sắc theo lỗi)
      final statusCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex));
      String statusText = 'Đúng giờ';
      String statusColor = '#16A34A'; // Xanh lá

      if (log.isLate && log.isEarlyLeave) {
        statusText = 'Muộn & Về sớm';
        statusColor = '#9333EA'; // Tím
      } else if (log.isLate) {
        statusText = 'Đi muộn';
        statusColor = '#EA580C'; // Cam
      } else if (log.isEarlyLeave) {
        statusText = 'Về sớm';
        statusColor = '#2563EB'; // Xanh dương
      }

      statusCell.value = TextCellValue(statusText);
      statusCell.cellStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString(statusColor),
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );
    }

    // 5. Tự động chỉnh độ rộng cột (Auto fit)
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 20.0);
    }

    final bytes = excel.save();
    if (bytes != null) {
      await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: 'attendance_report.xlsx');
    }
  }

  static Future<void> exportToPdf(List<AttendanceModel> logs) async {
    final pdf = pw.Document();
    
    // Tải font hỗ trợ Tiếng Việt
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Tính toán thống kê nhanh
    final totalAttendance = logs.where((e) => e.checkIn != null).length;
    final totalLate = logs.where((e) => e.isLate).length;
    final totalEmployees = logs.map((e) => e.uid).toSet().length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (context) => [
          // 1. HEADER (Dải màu đỏ UMC)
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFB91C1C),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CÔNG TY UMC VIỆT NAM', 
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Báo cáo chấm công chi tiết', 
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 14)),
                    pw.Text('Xuất ngày: ${DateHelper.toDisplayDate(DateTime.now())}', 
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  decoration: const pw.BoxDecoration(color: PdfColors.white, shape: pw.BoxShape.circle),
                  child: pw.Text(' UMC ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFFB91C1C))),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 15),

          // 2. SUMMARY CARDS
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _summaryCard('$totalEmployees', 'Tổng nhân viên'),
              _summaryCard('$totalAttendance', 'Lượt chấm công'),
              _summaryCard('$totalLate', 'Lượt đi muộn'),
              _summaryCard('0', 'Ngày vắng'),
            ],
          ),
          pw.SizedBox(height: 20),

          // 3. MAIN TABLE
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0F172A)),
            cellStyle: const pw.TextStyle(fontSize: 8, color: PdfColors.white),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1E293B)),
            rowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0F172A)),
            border: null,
            headers: ['#', 'Mã NV', 'Ngày', 'Ca', 'Check In', 'Check Out', 'Giờ làm', 'Khoảng cách', 'Trạng thái'],
            data: List.generate(logs.length, (index) {
              final log = logs[index];
              return [
                (index + 1).toString(),
                log.employeeCode,
                DateHelper.toDisplayDate(log.attendanceDate ?? DateTime.now()),
                log.shift == 'day' ? 'Ngày' : 'Đêm',
                log.checkIn != null ? DateHelper.toTimeString(log.checkIn!) : '--:--',
                log.checkOut != null ? DateHelper.toTimeString(log.checkOut!) : '--:--',
                '${log.calculatedWorkHours.toStringAsFixed(1)}h',
                '${log.distance.round()}m',
                log.isLate ? 'Đi muộn' : 'Đúng giờ',
              ];
            }),
            cellAlignment: pw.Alignment.center,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bao_cao_cham_cong.pdf',
    );
  }

  static pw.Widget _summaryCard(String value, String label) {
    return pw.Container(
      width: 170,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF334155),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(value, style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
        ],
      ),
    );
  }
}
