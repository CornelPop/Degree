import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hand_controller_app/AlertDialogs/ErrorDialogWidget.dart';
import 'package:hand_controller_app/AuthFeature/services/UserService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/TrainingProgramScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/widgets/ProgressBarWidget.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../../AuthFeature/models/User.dart';
import '../../GlobalThemeData.dart';
import '../../core/widgets/AppBarWidget.dart';
import '../models/Exercise.dart';
import '../models/TrainingProgram.dart';
import '../services/TrainingProgramService.dart';

class StartTrainingProgramScreen extends StatefulWidget {
  final TrainingProgram program;
  final User? user;

  const StartTrainingProgramScreen({Key? key, required this.program, required this.user}) : super(key: key);

  @override
  _StartTrainingProgramScreenState createState() => _StartTrainingProgramScreenState();
}

class _StartTrainingProgramScreenState extends State<StartTrainingProgramScreen> with TickerProviderStateMixin {
  List<List<Map<String, int>>> allValuesTakenForAccuracy = [];
  Map<String, double> finalAccuracy = {};

  Timer? _countdownTimer;
  Timer? _flexReadingTimer;

  bool isGloveActive = false;
  bool isGloveMounted = true;

  bool isInBasePosition = false;

  final Stopwatch _stopwatchEntireProgram = Stopwatch();

  late AnimationController _animationController;
  late Animation<double> _animation;

  int _currentTime = 20;
  int _currentExerciseIndex = -1;
  bool _isExerciseActive = false;

  int repetitions = 0;
  double accuracy = 0.0;

  bool _isPreparing = true;

  final UserService userService = UserService();
  final TrainingProgramService trainingProgramService = TrainingProgramService();

  int numberBeginnerExercises = 0;
  int numberIntermediateExercises = 0;
  int numberDifficultExercises = 0;
  int timeSpentInWorkouts = 0;

  late String uid;

  String flexSensorValue = '';
  bool isRequestInProgress = false;
  final String esp32IpAddress = "http://192.168.174.136";
  Map<String, int> currentFlexValues = {
    'Thumb': 0,
    'Index': 0,
    'Middle': 0,
    'Ring': 0,
    'Pinky': 0,
  };

  Map<String, dynamic> precisions = {
    'overallPrecision': 0.0,
    'fingerPrecisions': {},
  };

  @override
  void initState() {
    super.initState();
    uid = widget.user!.uid;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
      }
    });

    _startPreparationCountdown();
  }

  @override
  void dispose() {
    _cancelExistingTimers();
    _animationController.dispose();
    super.dispose();
  }

  void _startEntireProgramStopWatch() {
    _stopwatchEntireProgram.start();
  }

  void _endEntireProgramStopWatch() {
    _stopwatchEntireProgram.stop();
  }

  int lastFlexSum = 0;
  final int someThreshold = 0;

  void startFlexMonitoring() {
    DateTime lastActivityTime = DateTime.now();
    bool wasActive = false;

    _flexReadingTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) async {
      if (!mounted) {
        timer.cancel();
        _flexReadingTimer = null;
        return;
      }

      final flexValues = await readFlexSensor();

      if (flexValues != null) {
        final currentSum = flexValues.values.reduce((a, b) => a + b);

        if (currentSum > someThreshold) {
          lastActivityTime = DateTime.now();
          if (!wasActive) {
            wasActive = true;
            if (mounted) {
              setState(() {
                isGloveActive = true;
              });
            }
          }
        }
      }

      final timeSinceLastActivity = DateTime.now().difference(lastActivityTime);
      if (wasActive && timeSinceLastActivity > const Duration(seconds: 2)) {
        wasActive = false;
        setState(() {
          isGloveActive = false;
        });
      }
    });
  }

  void _startPreparationCountdown() {
    _cancelExistingTimers();
    setState(() {
      _isPreparing = true;
      _currentTime = 20;
    });

    _animationController.reset();
    _animationController.duration = const Duration(seconds: 20);
    _animationController.forward();

    startFlexMonitoring();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;

      _currentTime--;

      setState(() {});

      if (_currentTime == 0) {
        _cancelExistingTimers();

        if (isGloveActive && isGloveMounted) {
          _startExercise();
        } else {
          final retry = await ErrorDialogWidget(
            message: 'Glove is inactive or not worn. Try again.',
          ).showErrorDialog(context);

          if (retry == true) {
            _currentTime = 20;
            _animationController.reset();
            _animationController.duration = const Duration(seconds: 20);
            _animationController.forward();
            _startPreparationCountdown();
          }
        }
      }
    });

  }

  void _cancelExistingTimers() {
    _countdownTimer?.cancel();
    _flexReadingTimer?.cancel();
  }

  Future<Map<String, int>?> readFlexSensor() async {
    if (isRequestInProgress) return null;
    isRequestInProgress = true;

    try {
      final response = await http.get(Uri.parse("$esp32IpAddress/READ_FLEX_SENSOR_VALUES"));

      if (response.statusCode == 200) {
        List<String> values = response.body.trim().split(RegExp(r'\s+'));
        print(values);
        if (values.length == 5) {
          Map<String, int> flexValues = {
            'Thumb': int.parse(values[0]),
            'Index': int.parse(values[1]),
            'Middle': int.parse(values[2]),
            'Ring': int.parse(values[3]),
            'Pinky': int.parse(values[4]),
          };

          setState(() {
            currentFlexValues = flexValues;
          });

          return flexValues;
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Request failed: $e");
    } finally {
      isRequestInProgress = false;
    }

    return null;
  }

  Map<String, dynamic> calculatePrecisions(Map<String, int> targetValues, Map<String, int> userValues) {
    Map<String, double> fingerPrecisions = {};
    double totalPrecision = 0;
    int count = 0;

    targetValues.forEach((finger, target) {
      int actual = userValues[finger] ?? 0;

      double ratio = (actual - 1800) / (target - 1800);
      double precision = 100 - ((ratio - 1).abs() * 100);
      precision = precision.clamp(0.0, 100.0);

      fingerPrecisions[finger] = precision;
      totalPrecision += precision;
      count++;
    });

    double overallPrecision = count == 0 ? 0 : totalPrecision / count;

    return {
      "overallPrecision": overallPrecision,
      "fingerPrecisions": fingerPrecisions,
    };
  }

  double calculateExerciseAccuracy({
    required List<Map<String, int>> actualValuesPerRepetition,
    required Map<String, int> targetValues,
    required int expectedRepetitions,
  }) {
    int actualRepetitions = actualValuesPerRepetition.length;
    if (actualRepetitions == 0) return 0.0;

    double totalAccuracy = 0.0;

    for (var repetition in actualValuesPerRepetition) {
      double repetitionAccuracy = 0.0;

      for (var finger in targetValues.keys) {
        int target = targetValues[finger]!;
        int actual = repetition[finger] ?? 0;

        double accuracy = 1.0 - (actual - target).abs() / target;
        accuracy = accuracy.clamp(0.0, 1.0);

        repetitionAccuracy += accuracy;
      }

      repetitionAccuracy /= targetValues.length;
      totalAccuracy += repetitionAccuracy;
    }

    totalAccuracy /= actualRepetitions;

    double repetitionRatio = actualRepetitions / expectedRepetitions;
    repetitionRatio = repetitionRatio.clamp(0.0, 1.0);

    double finalAccuracy = totalAccuracy * repetitionRatio * 100;

    return finalAccuracy;
  }

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

  bool areBaseValuesReached(Map<String, int> currentFlexValues, Exercise exercise) {
    bool allMatch = true;

    Map<String, int> baseValues = exercise.baseValues;
    Map<String, int> targetValues = exercise.targetValues;

    List<String> movingFingers = [];

    baseValues.forEach((finger, baseValue) {
      if (targetValues.containsKey(finger)) {
        if ((baseValue - targetValues[finger]!).abs() > 100) {
          movingFingers.add(finger);
        }
      }
    });

    for (String finger in movingFingers) {
      if (currentFlexValues.containsKey(finger) && baseValues.containsKey(finger)) {
        if ((currentFlexValues[finger]! - baseValues[finger]!).abs() > 200) {
          allMatch = false;
          break;
        }
      }
    }

    return allMatch;
  }

  bool _wasInBasePosition = true;
  bool _isInBasePosition = true;
  List<Map<String, int>> _bestValuesPerRepetition = [];
  List<Map<String, int>> _currentRepetitionValues = [];

  void _startExercise() {
    if (_isExerciseActive) return;
    _isExerciseActive = true;

    setState(() {
      _isPreparing = false;
      _currentExerciseIndex++;
      _currentTime = 20;
      repetitions = 0;
      accuracy = 0;
      _wasInBasePosition = true;
      _isInBasePosition = true;
    });

    int requiredRepetitions = widget.program.exercises[_currentExerciseIndex].numberOfTimes;

    _animationController.duration = const Duration(seconds: 20);
    _animationController.reset();
    _animationController.forward();

    if (_currentExerciseIndex == 0) {
      _startEntireProgramStopWatch();
    }

    _flexReadingTimer?.cancel();

    _flexReadingTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (mounted) {
        readFlexSensor();

        _currentRepetitionValues.add(Map<String, int>.from(currentFlexValues));

        _wasInBasePosition = _isInBasePosition;
        _isInBasePosition = areBaseValuesReached(currentFlexValues, widget.program.exercises[_currentExerciseIndex]);

        // if (_isInBasePosition && !_wasInBasePosition  && repetitions < requiredRepetitions) {
        //
        //   if (_currentRepetitionValues.isNotEmpty) {
        //     _currentRepetitionValues.sort((a, b) {
        //       int sumA = a.values.reduce((v1, v2) => v1 + v2);
        //       int sumB = b.values.reduce((v1, v2) => v1 + v2);
        //       return sumB.compareTo(sumA);
        //     });
        //
        //     _bestValuesPerRepetition.add(_currentRepetitionValues.first);
        //     _currentRepetitionValues.clear();
        //   }
        //
        //   setState(() {
        //     repetitions++;
        //   });
        // }

        if (_isInBasePosition && !_wasInBasePosition && repetitions < requiredRepetitions) {
          // Get the current exercise
          final exercise = widget.program.exercises[_currentExerciseIndex];

          // Determine the moving fingers
          final Map<String, int> baseValues = exercise.baseValues;
          final Map<String, int> targetValues = exercise.targetValues;
          final List<String> movingFingers = [];

          baseValues.forEach((finger, baseValue) {
            if (targetValues.containsKey(finger)) {
              if ((baseValue - targetValues[finger]!).abs() > 100) {
                movingFingers.add(finger);
              }
            }
          });

          if (_currentRepetitionValues.isNotEmpty) {
            // Only consider values of moving fingers when comparing for best
            _currentRepetitionValues.sort((a, b) {
              int sumA = movingFingers.fold(0, (sum, finger) => sum + (a[finger] ?? 0));
              int sumB = movingFingers.fold(0, (sum, finger) => sum + (b[finger] ?? 0));
              return sumB.compareTo(sumA); // descending: higher movement first
            });

            // Extract only the relevant fingers into the best value
            Map<String, int> bestForMovingFingers = {
              for (var finger in movingFingers)
                if (_currentRepetitionValues.first.containsKey(finger))
                  finger: _currentRepetitionValues.first[finger]!
            };

            _bestValuesPerRepetition.add(bestForMovingFingers);
            _currentRepetitionValues.clear();
          }

            setState(() {
              repetitions++;
            });
        }
      } else {
        timer.cancel();
        _flexReadingTimer = null;
      }
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime--;
        });

        if (_currentTime == 0) {
          _cancelExistingTimers();
          _isExerciseActive = false;

          List<Map<String, int>> top = _bestValuesPerRepetition.take(requiredRepetitions).toList();

          // print("Top best values (one per repetition):");
          // for (var i = 0; i < top.length; i++) {
          //   print("${i + 1}: ${top[i]}");
          // }

          allValuesTakenForAccuracy.add(top);

          _bestValuesPerRepetition.clear();
          _currentRepetitionValues.clear();

          // // Map<String, int> targetValues = widget.program.exercises[_currentExerciseIndex].targetValues;
          // // Map<String, int> userValues = Map<String, int>.from(currentFlexValues);
          // //
          // // var precisions = calculatePrecisions(targetValues, userValues);
          // //
          // // print("Exercise ${_currentExerciseIndex + 1} - Overall Precision: ${precisions['overallPrecision']}%");
          // // print("Finger Precisions: ${precisions['fingerPrecisions']}");
          // // print("Repetitions: $repetitions");
          //
          // setState(() {
          //   accuracy = precisions['overallPrecision'];
          // });

          if (_currentExerciseIndex < widget.program.exercises.length - 1) {
            _startExercise();
          } else {

            finalAccuracy = calculateAverageAccuracyPerFinger(exercises: widget.program.exercises, allValuesTakenForAccuracy: allValuesTakenForAccuracy);
            print('${finalAccuracy} here');

            _endEntireProgramStopWatch();
            _cancelExistingTimers();
            widget.program.allValuesTakenForAccuracy = allValuesTakenForAccuracy;
            _addTrainingProgramToCompleted(widget.program);
            _updateExerciseCounter(widget.program.category, _stopwatchEntireProgram.elapsed.inSeconds, finalAccuracy);
            _showCompletionDialog();
          }
        }
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        double total = 0;
        int count = 0;

        finalAccuracy.forEach((finger, accuracy) {
          if (accuracy != -1) {
            total += accuracy;
            count++;
          }
        });

        double averageAccuracy = count > 0 ? total / count : 0.0;

        return AlertDialog(
          title: const Text(
            "Program Completed",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          content: SizedBox(
            width: screenWidth * 0.8,
            height: screenHeight * 0.4,
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Congratulations! You have completed the program.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ProgressBarWidget(
                      percentage: averageAccuracy,
                      text: 'Accuracy for this program',
                      rounded: true,
                      isWhite: false,
                    ),
                    const SizedBox(height: 10),
                    ProgressBarWidget(
                      percentage: finalAccuracy['Thumb'] ?? -1.0,
                      text: 'Thumb',
                      rounded: false,
                      isWhite: false,
                    ),
                    ProgressBarWidget(
                      percentage: finalAccuracy['Index'] ?? -1.0,
                      text: 'Index',
                      rounded: false,
                      isWhite: false,
                    ),
                    ProgressBarWidget(
                      percentage: finalAccuracy['Middle'] ?? -1.0,
                      text: 'Middle',
                      rounded: false,
                      isWhite: false,
                    ),
                    ProgressBarWidget(
                      percentage: finalAccuracy['Ring'] ?? -1.0,
                      text: 'Ring',
                      rounded: false,
                      isWhite: false,
                    ),
                    ProgressBarWidget(
                      percentage: finalAccuracy['Pinky'] ?? -1.0,
                      text: 'Pinky',
                      rounded: false,
                      isWhite: false,
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const TrainingProgramScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: CustomTheme.accentColor2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateExerciseCounter(String category, int? timeSpent, Map<String, double> finalAccuracy) async {
    Map<String, dynamic>? userData = await userService.getUserData(uid);

    if (userData != null) {
      // Actualizează timpul total
      timeSpentInWorkouts = userData['timeSpentInWorkouts'] as int? ?? 0;
      timeSpentInWorkouts += timeSpent ?? 0;
      await userService.updateUserField(uid, 'timeSpentInWorkouts', timeSpentInWorkouts);

      // Calculează media acurateții pe baza finalAccuracy
      double total = 0.0;
      int count = 0;

      finalAccuracy.forEach((finger, value) {
        if (value != -1) {
          total += value;
          count++;
        }
      });

      double averageAccuracy = count > 0 ? total / count : 0.0;

      // Citește acuratețea existentă din DB în siguranță
      double currentAccuracy = (userData['accuracyOfExercises'] as num?)?.toDouble() ?? 0.0;

      // Calculează noua medie (sau setează direct dacă e prima)
      double updatedAccuracy = currentAccuracy == 0.0
          ? averageAccuracy
          : (currentAccuracy + averageAccuracy) / 2;

      await userService.updateUserField(uid, 'accuracyOfExercises', updatedAccuracy);

      // Actualizează contorii de exerciții pe categorie
      if (category == 'Beginner') {
        numberBeginnerExercises = userData['numberBeginnerExercises'] as int? ?? 0;
        numberBeginnerExercises++;
        await userService.updateUserField(uid, 'numberBeginnerExercises', numberBeginnerExercises);
      } else if (category == 'Intermediate') {
        numberIntermediateExercises = userData['numberIntermediateExercises'] as int? ?? 0;
        numberIntermediateExercises++;
        await userService.updateUserField(uid, 'numberIntermediateExercises', numberIntermediateExercises);
      } else if (category == 'Difficult') {
        numberDifficultExercises = userData['numberDifficultExercises'] as int? ?? 0;
        numberDifficultExercises++;
        await userService.updateUserField(uid, 'numberDifficultExercises', numberDifficultExercises);
      }
    }
  }

  Future<void> _addTrainingProgramToCompleted(TrainingProgram trainingProgram) async {
    List<Map<String, dynamic>> serializedList = [];

    for (int exerciseIndex = 0; exerciseIndex < allValuesTakenForAccuracy.length; exerciseIndex++) {
      print("Exercise ${exerciseIndex + 1}:");
      List<Map<String, int>> reps = allValuesTakenForAccuracy[exerciseIndex];

      for (int repIndex = 0; repIndex < reps.length; repIndex++) {
        print("  Repetition ${repIndex + 1}: ${reps[repIndex]}");
      }
    }

    for (var repetition in allValuesTakenForAccuracy) {
      serializedList.add({'repetition': repetition});
    }

    await trainingProgramService.addCompletedProgram(uid, trainingProgram);
    await trainingProgramService.updateAccuracyValuesForCompletedProgram(uid, trainingProgram, serializedList);
  }

  String _formatTime(int seconds) {
    return '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // App bar background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            height: kToolbarHeight + 20,
          ),
          Column(
            children: [
              AppBarWidget(leadingIcon: Icons.arrow_back),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Center(
                    child: _isPreparing
                        ? _buildPreparationPhase()
                        : _buildExercisePhase(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationPhase() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Get ready to start the program!",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 125,
                    height: 125,
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 10,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(CustomTheme.accentColor2),
                    ),
                  ),
                  Text(
                    _formatTime(_currentTime),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Make sure the glove is on the right position",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Glove Status: ",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                isGloveActive ? "Active" : "Inactive",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isGloveActive ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(width: 5,),
              Icon(isGloveActive ? Icons.check : Icons.close, color: isGloveActive ? Colors.green : Colors.red,)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExercisePhase() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.program.exercises[_currentExerciseIndex].name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'x${widget.program.exercises[_currentExerciseIndex].numberOfTimes}',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Exercise animation
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Lottie.asset(
                widget.program.exercises[_currentExerciseIndex].animationPath,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 125,
            height: 125,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(75),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 10,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(CustomTheme.accentColor2),
                    ),
                  ),
                  Text(
                    _formatTime(_currentTime),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text('Repetitions done: ${repetitions}', style: TextStyle(color: Colors.white),),
          // Next exercise button
          Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  CustomTheme.accentColor4,
                  CustomTheme.accentColor2,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ],
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton(
              onPressed: () async {
                _cancelExistingTimers();
                if (_currentExerciseIndex < widget.program.exercises.length - 1) {
                  _isExerciseActive = false;
                  _startExercise();
                } else {
                  _updateExerciseCounter(widget.program.category, _stopwatchEntireProgram.elapsed.inSeconds, finalAccuracy);
                  _addTrainingProgramToCompleted(widget.program);
                  _showCompletionDialog();
                  _cancelExistingTimers();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Skip to Next",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Glove Status: ",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                isGloveActive ? "Active" : "Inactive",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isGloveActive ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(width: 5,),
              Icon(isGloveActive ? Icons.check : Icons.close, color: isGloveActive ? Colors.green : Colors.red,)
            ],
          ),
        ],
      ),
    );
  }
}