import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this for date formatting
import 'package:hand_controller_app/TrainingProgramsFeature/models/TrainingProgram.dart';

class LastWeekTotalNumberLineChart extends StatelessWidget {
  final List<TrainingProgram> completedPrograms;

  const LastWeekTotalNumberLineChart({Key? key, required this.completedPrograms}) : super(key: key);

  List<FlSpot> _generateSpots() {
    DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    Map<String, int> programsPerDay = {};

    for (var program in completedPrograms) {
      if (program.date.isAfter(oneWeekAgo)) {
        String dateStr = DateFormat('yyyy-MM-dd').format(program.date);

        if (programsPerDay.containsKey(dateStr)) {
          programsPerDay[dateStr] = programsPerDay[dateStr]! + 1;
        } else {
          programsPerDay[dateStr] = 1;
        }
      }
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: 6 - i));
      String dateStr = DateFormat('yyyy-MM-dd').format(date);
      int count = programsPerDay[dateStr] ?? 0;
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.2), // White grid lines
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  DateTime date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      DateFormat('MM/dd').format(date),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      value.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          backgroundColor: Colors.transparent,
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 20,
          lineBarsData: [
            LineChartBarData(
              spots: _generateSpots(),
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
            ),
          ],
        ),
      ),
    );
  }
}
