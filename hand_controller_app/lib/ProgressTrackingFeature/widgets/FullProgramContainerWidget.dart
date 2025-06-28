import 'package:flutter/material.dart';

import '../../AuthFeature/models/User.dart';
import '../../GlobalThemeData.dart';
import '../../TrainingProgramsFeature/models/TrainingProgram.dart';
import '../../TrainingProgramsFeature/screens/ProgramDetailsScreen.dart';
import 'ProgramAnalyticsScreen.dart';

class FullProgramContainerWidget extends StatelessWidget {
  final TrainingProgram program;
  final User? user;
  final String title;
  final String date;
  final String subtitle;
  final String difficulty;
  final bool isDone;
  final bool viewMore;
  final List<TrainingProgram> favoriteTrainingPrograms;
  final void Function(String programId, bool isNowFavorite) onFavoriteChanged;

  FullProgramContainerWidget(
      {required this.program,
      required this.title,
      required this.date,
      required this.subtitle,
      required this.difficulty,
      required this.user,
      required this.favoriteTrainingPrograms,
      required this.onFavoriteChanged,
      required this.isDone,
      required this.viewMore});

  @override
  Widget build(BuildContext context) {
    bool isFavorite = favoriteTrainingPrograms.any(
      (p) => p.trainingProgramId == program.trainingProgramId,
    );
    Color? iconColor;
    List<double> opacities;
    Color bgColor;

    if (difficulty == 'Beginner') {
      iconColor = Colors.blue[900];
      opacities = [1.0, 0.3, 0.3];
      bgColor = CustomTheme.accentColor;
    } else if (difficulty == 'Intermediate') {
      iconColor = Colors.blue[900];
      opacities = [1.0, 1.0, 0.3];
      bgColor = CustomTheme.accentColor2;
    } else {
      iconColor = Colors.blue[900];
      opacities = [1.0, 1.0, 1.0];
      bgColor = CustomTheme.accentColor3;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgramDetailsScreen(
              user: user,
              isFavorite: isFavorite,
              program: program,
              onFavoriteChanged: onFavoriteChanged,
            ),
          ),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.15,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white),
                ),
                isDone
                    ? Text(
                        date,
                        style: TextStyle(color: Colors.white),
                      )
                    : Container(),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Opacity(
                      opacity: opacities[index],
                      child: Icon(Icons.bolt, color: iconColor, size: 30),
                    );
                  }),
                ),
              ],
            ),
            viewMore ? Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white70, // White background
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: bgColor),
                    tooltip: 'See more details',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProgramAnalyticsScreen(
                            trainingProgram: program,
                            user: user,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
            : Container(),
          ],
        ),
      ),
    );
  }
}
