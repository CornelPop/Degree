import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/services/AuthService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/models/Exercise.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/services/ExerciseService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/services/TrainingProgramService.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import '../../AuthFeature/models/User.dart';
import '../../AuthFeature/services/UserService.dart';
import '../../GlobalThemeData.dart';
import '../../TrainingProgramsFeature/models/TrainingProgram.dart';
import '../../TrainingProgramsFeature/widgets/ProgressBarWidget.dart';

class ProgramAnalyticsScreen extends StatefulWidget {
  final User? user;
  final TrainingProgram trainingProgram;
  const ProgramAnalyticsScreen({Key? key, required this.user, required this.trainingProgram}) : super(key: key);

  @override
  ProgramAnalyticsScreenState createState() =>
      ProgramAnalyticsScreenState();
}

class ProgramAnalyticsScreenState extends State<ProgramAnalyticsScreen> {
  final UserService userService = UserService();
  final AuthService authService = AuthService();
  final TrainingProgramService trainingProgramService = TrainingProgramService();
  final ExerciseService exerciseService = ExerciseService();

  Map<String, double> finalAccuracy = {};

  List<String> fingers = ['Index', 'Thumb', 'Middle', 'Ring', 'Pinky'];

  List<Exercise> exercises = [];

  double total = 0;
  int count = 0;

  double averageAccuracy = 0;

  Map<String, double> calculateAverageAccuracyPerFinger({
    required List<Exercise> exercises,
    required List<List<Map<String, int>>> allValuesTakenForAccuracy,
  }) {
    // Accumulators
    Map<String, double> fingerAccuracySum = {};
    Map<String, int> fingerAccuracyCount = {};
    Map<String, int> fingerExpectedReps = {};
    Set<String> allFingers = {'Thumb', 'Index', 'Middle', 'Ring', 'Pinky'};

    for (int i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      final reps = allValuesTakenForAccuracy[i];
      final expectedReps = exercise.numberOfTimes;

      // Determine moving fingers
      final movingFingers = <String>[];
      exercise.baseValues.forEach((finger, baseVal) {
        if (exercise.targetValues.containsKey(finger)) {
          final targetVal = exercise.targetValues[finger]!;
          if ((baseVal - targetVal).abs() > 100) {
            movingFingers.add(finger);
          }
        }
      });

      for (var rep in reps) {
        for (var finger in movingFingers) {
          if (rep.containsKey(finger) && exercise.targetValues.containsKey(finger)) {
            final actual = rep[finger]!;
            final target = exercise.targetValues[finger]!;
            double accuracy = 1.0 - (actual - target).abs() / target;
            accuracy = accuracy.clamp(0.0, 1.0);

            fingerAccuracySum[finger] = (fingerAccuracySum[finger] ?? 0) + accuracy;
            fingerAccuracyCount[finger] = (fingerAccuracyCount[finger] ?? 0) + 1;
          }
        }
      }

      for (var finger in movingFingers) {
        fingerExpectedReps[finger] = (fingerExpectedReps[finger] ?? 0) + expectedReps;
      }
    }

    // Final map to return
    Map<String, double> finalAccuracies = {};

    for (var finger in allFingers) {
      if (fingerAccuracyCount.containsKey(finger)) {
        final totalAcc = fingerAccuracySum[finger]!;
        final count = fingerAccuracyCount[finger]!;
        final expected = fingerExpectedReps[finger] ?? count;

        // Repetition ratio factor
        double repRatio = count / expected;
        repRatio = repRatio.clamp(0.0, 1.0);

        final average = (totalAcc / count) * repRatio * 100;
        finalAccuracies[finger] = double.parse(average.toStringAsFixed(2));
      } else {
        finalAccuracies[finger] = -1.0;
      }
    }

    return finalAccuracies;
  }

  @override
  void initState() {
    super.initState();

    print(widget.trainingProgram);

    exercises = widget.trainingProgram.exercises;
    print(exercises);
    print(widget.trainingProgram.allValuesTakenForAccuracy);
    finalAccuracy = calculateAverageAccuracyPerFinger(exercises: exercises, allValuesTakenForAccuracy: widget.trainingProgram.allValuesTakenForAccuracy);

    finalAccuracy.forEach((finger, accuracy) {
      if (accuracy != -1) {
        total += accuracy;
        count++;
      }
    });

    averageAccuracy = count > 0 ? total / count : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: programAnalyticsWidget()
    );
  }

  Widget programAnalyticsWidget() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              height: kToolbarHeight + 20,
            ),
            Column(
              children: [
                AppBarWidget(
                  leadingIcon: Icons.arrow_back,
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Analytics for the entire program:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  ProgressBarWidget(
                    percentage: averageAccuracy,
                    text: 'Accuracy for the entire program',
                    rounded: true,
                    isWhite: true,
                  ),
                  const SizedBox(height: 10),
                  ProgressBarWidget(
                    percentage: finalAccuracy['Thumb'] ?? -1.0,
                    text: 'Thumb',
                    rounded: false,
                    isWhite: true,
                  ),
                  ProgressBarWidget(
                    percentage: finalAccuracy['Index'] ?? -1.0,
                    text: 'Index',
                    rounded: false,
                    isWhite: true,
                  ),
                  ProgressBarWidget(
                    percentage: finalAccuracy['Middle'] ?? -1.0,
                    text: 'Middle',
                    rounded: false,
                    isWhite: true,
                  ),
                  ProgressBarWidget(
                    percentage: finalAccuracy['Ring'] ?? -1.0,
                    text: 'Ring',
                    rounded: false,
                    isWhite: true,
                  ),
                  ProgressBarWidget(
                    percentage: finalAccuracy['Pinky'] ?? -1.0,
                    text: 'Pinky',
                    rounded: false,
                    isWhite: true,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Analytics for each exercise:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final reps = widget.trainingProgram.allValuesTakenForAccuracy[index];

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        color: Colors.white.withOpacity(0.1),
                        key: Key('$index'),
                        child: ExpansionTile(
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          title: Text(
                            exercises[index].name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          leading: Icon(Icons.expand_more, color: Colors.white),
                          trailing: const SizedBox.shrink(),
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Repetitions: ${exercises[index].numberOfTimes}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            ...List.generate(reps.length, (repIndex) {
                              final values = reps[repIndex];
                              final isRepDone = values.values.any((v) => v != -1);

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rep ${repIndex + 1}:',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (!isRepDone)
                                      const Text(
                                        'Repetition not done',
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    else
                                      ...fingers.map((finger) {
                                        final val = values[finger] ?? -1.0;
                                        if (val == -1) {
                                          return ProgressBarWidget(
                                            percentage: -1.0,
                                            text: finger,
                                            rounded: false,
                                            isWhite: true,
                                          );
                                        } else {
                                          final target = exercises[index].targetValues[finger];

                                          double accuracy = 1.0 - (val - target!).abs() / target;
                                          accuracy = accuracy.clamp(0.0, 1.0); // Ensure it's between 0 and 1
                                          final percentage = accuracy * 100; // Convert to percentage

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ProgressBarWidget(
                                                  percentage: percentage,
                                                  text: finger,
                                                  rounded: false,
                                                  isWhite: true,
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }).toList(),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20,)
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
