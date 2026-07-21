import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/attendance_model.dart';
import '../models/user_model.dart';

class ReportService {
  // Generate PDF report
  static Future<File?> generatePdfReport({
    required List<AttendanceModel> attendances,
    required String title,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            if (startDate != null && endDate != null)
              pw.Paragraph(
                text: 'Period: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
              ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Date', 'Name', 'Email', 'Status', 'Check-in Time'],
              data: attendances.map((a) => [
                DateFormat('MMM dd, yyyy').format(a.date),
                a.userName,
                a.userEmail,
                a.statusDisplayName,
                a.checkInTime != null 
                    ? DateFormat('HH:mm').format(a.checkInTime!)
                    : 'N/A',
              ]).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total Records: ${attendances.length}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      print('Error generating PDF report: $e');
      return null;
    }
  }

  // Generate Excel report
  static Future<File?> generateExcelReport({
    required List<AttendanceModel> attendances,
    required String title,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Attendance Report'];

      // Add title
      sheet.appendRow([TextCellValue(title)]);
      
      if (startDate != null && endDate != null) {
        sheet.appendRow([
          TextCellValue('Period: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}')
        ]);
      }
      
      sheet.appendRow([]); // Empty row

      // Add headers
      sheet.appendRow([
        TextCellValue('Date'),
        TextCellValue('Name'),
        TextCellValue('Email'),
        TextCellValue('Room'),
        TextCellValue('Status'),
        TextCellValue('Check-in Time'),
        TextCellValue('Location'),
        TextCellValue('Manual Entry'),
        TextCellValue('Approved By'),
      ]);

      // Add data
      for (final attendance in attendances) {
        sheet.appendRow([
          TextCellValue(DateFormat('MMM dd, yyyy').format(attendance.date)),
          TextCellValue(attendance.userName),
          TextCellValue(attendance.userEmail),
          TextCellValue(attendance.roomId ?? 'N/A'),
          TextCellValue(attendance.statusDisplayName),
          TextCellValue(attendance.checkInTime != null 
              ? DateFormat('HH:mm').format(attendance.checkInTime!)
              : 'N/A'),
          TextCellValue(attendance.address ?? 'N/A'),
          TextCellValue(attendance.isManualEntry ? 'Yes' : 'No'),
          TextCellValue(attendance.approvedBy ?? 'N/A'),
        ]);
      }

      // Add summary
      sheet.appendRow([]);
      sheet.appendRow([TextCellValue('Total Records:'), TextCellValue(attendances.length.toString())]);
      sheet.appendRow([TextCellValue('Present:'), TextCellValue(attendances.where((a) => a.isPresent).length.toString())]);
      sheet.appendRow([TextCellValue('Late:'), TextCellValue(attendances.where((a) => a.isLate).length.toString())]);
      sheet.appendRow([TextCellValue('Absent:'), TextCellValue(attendances.where((a) => a.isAbsent).length.toString())]);

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
      
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        return file;
      }
      
      return null;
    } catch (e) {
      print('Error generating Excel report: $e');
      return null;
    }
  }

  // Generate student summary report
  static Future<File?> generateStudentSummaryPdf({
    required List<UserModel> students,
    required Map<String, List<AttendanceModel>> attendanceByStudent,
    required String title,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            if (startDate != null && endDate != null)
              pw.Paragraph(
                text: 'Period: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
              ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Name', 'Email', 'Room', 'Present', 'Late', 'Absent', 'Rate'],
              data: students.map((student) {
                final attendances = attendanceByStudent[student.id] ?? [];
                final present = attendances.where((a) => a.isPresent).length;
                final late = attendances.where((a) => a.isLate).length;
                final total = attendances.length;
                final rate = total > 0 
                    ? ((present + late) / total * 100).toStringAsFixed(1)
                    : '0.0';
                
                return [
                  student.fullName,
                  student.email,
                  student.roomId ?? 'N/A',
                  present.toString(),
                  late.toString(),
                  (total - present - late).toString(),
                  '$rate%',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/student_summary_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      print('Error generating student summary PDF: $e');
      return null;
    }
  }

  // Calculate attendance statistics
  static Map<String, dynamic> calculateStatistics(List<AttendanceModel> attendances) {
    final total = attendances.length;
    final present = attendances.where((a) => a.isPresent).length;
    final late = attendances.where((a) => a.isLate).length;
    final absent = attendances.where((a) => a.isAbsent).length;
    final excused = attendances.where((a) => a.isExcused).length;

    return {
      'total': total,
      'present': present,
      'late': late,
      'absent': absent,
      'excused': excused,
      'attendanceRate': total > 0 
          ? ((present + late) / total * 100).toStringAsFixed(1)
          : '0.0',
    };
  }
}
