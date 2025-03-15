import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../TrainingProgramsFeature/models/TrainingProgram.dart';

class PdfService {
  Future<void> generateAndSavePDF(String userName, List<TrainingProgram> completedPrograms) async {
    final pdf = pw.Document();
    String filename = 'Generated Reports.pdf';
    String title = 'HandHero Generated Reports';
    String description = 'Hello $userName, this report contains the details of your completed training programs.';

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
                  'Completed Programs:',
                  style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );

    for (var program in completedPrograms) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Padding(
              padding: pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Program Name: ${program.name}',
                    style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Category: ${program.category}',
                    style: pw.TextStyle(font: ttf, fontSize: 12),
                  ),
                  pw.Text(
                    'Duration: ${program.duration} minutes',
                    style: pw.TextStyle(font: ttf, fontSize: 12),
                  ),
                  pw.Text(
                    'Date Completed: ${program.date.toLocal()}',
                    style: pw.TextStyle(font: ttf, fontSize: 12),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Exercises:',
                    style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 5),
                  if (program.exercises.isNotEmpty)
                  // Split exercises into groups of 4 for column layout
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: List.generate(
                        (program.exercises.length / 4).ceil(),
                            (columnIndex) {
                          int startIndex = columnIndex * 4;
                          int endIndex = startIndex + 4;
                          if (endIndex > program.exercises.length) endIndex = program.exercises.length;
                          List<pw.Widget> exercisesInColumn = program.exercises
                              .sublist(startIndex, endIndex)
                              .map((exercise) {
                            return pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Exercise: ${exercise.name}',
                                  style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.Text(
                                  'Reps: ${exercise.numberOfTimes}',
                                  style: pw.TextStyle(font: ttf, fontSize: 12),
                                ),
                                pw.Text(
                                  'Target Values:',
                                  style: pw.TextStyle(font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.Column(
                                  children: exercise.targetValues.entries.map((entry) {
                                    return pw.Text(
                                      '${entry.key}: ${entry.value}',
                                      style: pw.TextStyle(font: ttf, fontSize: 12),
                                    );
                                  }).toList(),
                                ),
                                pw.SizedBox(height: 10),
                              ],
                            );
                          }).toList();

                          return pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: exercisesInColumn,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    pw.Text(
                      'No exercises available for this program.',
                      style: pw.TextStyle(font: ttf, fontSize: 12, fontStyle: pw.FontStyle.italic),
                    ),
                  pw.SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      );
    }

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
