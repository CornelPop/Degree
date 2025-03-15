import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hand_controller_app/GlobalThemeData.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/models/TrainingProgram.dart';

class LastMonthTotalNumberByCategoryPieChart extends StatelessWidget {
  final List<TrainingProgram> completedPrograms;

  const LastMonthTotalNumberByCategoryPieChart({Key? key, required this.completedPrograms}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int beginnerCount = completedPrograms
        .where((program) => program.category == 'Beginner')
        .length;
    int intermediateCount = completedPrograms
        .where((program) => program.category == 'Intermediate')
        .length;
    int advancedCount = completedPrograms
        .where((program) => program.category == 'Difficult')
        .length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: beginnerCount.toDouble(),
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  color: CustomTheme.accentColor,
                  radius: 60,
                  showTitle: true,
                ),
                PieChartSectionData(
                  value: intermediateCount.toDouble(),
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  color: CustomTheme.accentColor2,
                  radius: 60,
                  showTitle: true,
                ),
                PieChartSectionData(
                  value: advancedCount.toDouble(),
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  color: CustomTheme.accentColor3,
                  radius: 60,
                  showTitle: true,
                ),
              ],
              sectionsSpace: 5,
              centerSpaceRadius: 60,
              borderData: FlBorderData(show: false),
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(CustomTheme.accentColor, 'Beginner'),
            const SizedBox(width: 10),
            _buildLegendItem(CustomTheme.accentColor2, 'Intermediate'),
            const SizedBox(width: 10),
            _buildLegendItem(CustomTheme.accentColor3, 'Advanced'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
