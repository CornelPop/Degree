import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/models/TrainingProgram.dart';
import 'package:intl/intl.dart';

class TrainingDurationStackedBarChart extends StatelessWidget {
  final List<TrainingProgram> completedPrograms;

  const TrainingDurationStackedBarChart({Key? key, required this.completedPrograms}) : super(key: key);

  List<BarChartGroupData> _generateBarChartData() {
    Map<String, double> durationsPerDay = {};

    for (var program in completedPrograms) {
      String dateStr = DateFormat('yyyy-MM-dd').format(program.date);
      double programDuration = program.duration.toDouble();

      if (durationsPerDay.containsKey(dateStr)) {
        durationsPerDay[dateStr] = durationsPerDay[dateStr]! + programDuration;
      } else {
        durationsPerDay[dateStr] = programDuration;
      }
    }

    List<BarChartGroupData> barData = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: 6 - i));
      String dateStr = DateFormat('yyyy-MM-dd').format(date);

      double totalDuration = durationsPerDay[dateStr] ?? 0.0;
      barData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              fromY: 0,
              toY: totalDuration,
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return barData;
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        gridData: FlGridData(show: true),
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
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: true),
        barGroups: _generateBarChartData(),
      ),
    );
  }
}
