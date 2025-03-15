import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:pdf/pdf.dart';
import '../models/MedicalHistory.dart';
import 'package:open_file/open_file.dart';

class PdfProfileService {
  Future<void> generateAndSavePDFSpecificConsultation(String userName, Consultation consultation) async {
    final pdf = pw.Document();
    String filename = 'Medical_History_Report.pdf';
    String title = 'Medical History Report';
    String description = 'Hello $userName, this report contains details of your consultation.';

    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(font: ttf, fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  description,
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Consultation Details:',
                  style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Title: ${consultation.title}',
                  style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Date: ${consultation.date}',
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                ),
                pw.Text(
                  'Treatment Plan: ${consultation.treatmentPlan}',
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                ),
                pw.Text(
                  'Notes: ${consultation.notes}',
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );

    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(await pdf.save());
        final result = await OpenFile.open(file.path);
        print('OpenFile result: $result');
      } else {
        print('External storage directory is null.');
      }
    } catch (e) {
      print('Error generating or saving PDF: $e');
    }
  }
}
