import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/services/UserService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/TrainingProgramScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/widgets/CountdownTimerWidget.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/widgets/ProgressBarWidget.dart';
import 'package:http/http.dart' as http;

import '../../AuthFeature/models/User.dart';
import '../../GlobalThemeData.dart';
import '../../core/widgets/AppBarWidget.dart';
import '../models/TrainingProgram.dart';
import '../services/TrainingProgramService.dart';

class StartTrainingProgramScreen extends StatefulWidget {
  final TrainingProgram program;
  final User? user;

  StartTrainingProgramScreen({Key? key, required this.program, required this.user}) : super(key: key);

  @override
  _StartTrainingProgramScreenState createState() => _StartTrainingProgramScreenState();
}

class _StartTrainingProgramScreenState extends State<StartTrainingProgramScreen> with TickerProviderStateMixin {
  Timer? _countdownTimer;
  Timer? _flexReadingTimer;
  final Stopwatch _stopwatchEntireProgram = Stopwatch();
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentTime = 1;
  int _currentExerciseIndex = -1;
  bool _isExerciseActive = false;

  final UserService userService = UserService();
  final TrainingProgramService trainingProgramService = TrainingProgramService();

  int numberBeginnerExercises = 0;
  int numberIntermediateExercises = 0;
  int numberDifficultExercises = 0;
  int timeSpentInWorkouts = 0;

  late String uid;

  String flexSensorValue = '';
  bool isRequestInProgress = false;
  final String esp32IpAddress = "http://192.168.217.136";
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
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);
    _startCountdown();
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

  void _startCountdown() {
    _cancelExistingTimers();
    _animationController.reset();
    _animationController.forward();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime--;
        if (_currentTime == 0) {
          _cancelExistingTimers();
          _startExercise();
        }
      });
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

      // Calculate precision based on the ratio, adjusted to the range 1800-2800
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


  void _startExercise() {
    if (_isExerciseActive) return;
    _isExerciseActive = true;

    setState(() {
      _currentExerciseIndex++;
      _currentTime = 1;
    });

    _animationController.reset();
    _animationController.forward();

    if (_currentExerciseIndex == 0) {
      _startEntireProgramStopWatch();
    }

    _flexReadingTimer?.cancel();

    _flexReadingTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (mounted) {
        readFlexSensor();
      } else {
        timer.cancel();
        _flexReadingTimer = null;
      }
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime--;

          if (_currentTime == 0) {
            _cancelExistingTimers();
            _isExerciseActive = false;

            Map<String, int> targetValues =
                widget.program.exercises[_currentExerciseIndex].targetValues;

            Map<String, int> userValues = Map<String, int>.from(currentFlexValues); // Use latest values

            precisions = calculatePrecisions(targetValues, userValues);

            print("Exercise ${_currentExerciseIndex + 1} - Overall Precision: ${precisions['overallPrecision']}%");
            print("Finger Precisions: ${precisions['fingerPrecisions']}");

            if (_currentExerciseIndex < widget.program.exercises.length - 1) {
              _startExercise();
            } else {
              _endEntireProgramStopWatch();
              _cancelExistingTimers();
              _addTrainingProgramToCompleted(widget.program);
              _updateExerciseCounter(widget.program.category, _stopwatchEntireProgram.elapsed.inSeconds);
              _showCompletionDialog();
            }
          }
        });
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

        return AlertDialog(
          title: const Text("Program Completed"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          content: Container(
            width: screenWidth * 0.8,
            height: screenHeight * 0.4,
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Congratulations! You have completed the program."),
                    const SizedBox(height: 20),
                    ProgressBarWidget(
                      percentage: precisions['overallPrecision'],
                      text: 'Accuracy for this program',
                      rounded: true,
                    ),
                    ProgressBarWidget(
                      percentage: precisions['fingerPrecisions']['Thumb'],
                      text: 'Thumb',
                      rounded: false,
                    ),
                    ProgressBarWidget(
                      percentage: precisions['fingerPrecisions']['Index'],
                      text: 'Index',
                      rounded: false,
                    ),
                    ProgressBarWidget(
                      percentage: precisions['fingerPrecisions']['Middle'],
                      text: 'Middle',
                      rounded: false,
                    ),
                    ProgressBarWidget(
                      percentage: precisions['fingerPrecisions']['Ring'],
                      text: 'Ring',
                      rounded: false,
                    ),
                    ProgressBarWidget(
                      percentage: precisions['fingerPrecisions']['Pinky'],
                      text: 'Pinky',
                      rounded: false,
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
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateExerciseCounter(String category, int? timeSpent) async {
    Map<String, dynamic>? userData = await userService.getUserData(uid);
    if (userData != null) {

      timeSpentInWorkouts = userData['timeSpentInWorkouts'] as int? ?? 0;
      timeSpentInWorkouts += timeSpent ?? 0;
      await userService.updateUserField(uid, 'timeSpentInWorkouts', timeSpentInWorkouts);

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
    await trainingProgramService.addCompletedProgram(uid, trainingProgram);
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background for the Top Container
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
                    child: _currentExerciseIndex == -1
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Get ready to start the program!",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        CountdownTimer(currentTime: _currentTime, animation: _animation),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.program.exercises[_currentExerciseIndex].name,
                          style: const TextStyle(fontSize: 24, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        CountdownTimer(currentTime: _currentTime, animation: _animation),
                        const SizedBox(height: 20),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
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
                                offset: Offset(0, 0),
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
                                _updateExerciseCounter(widget.program.category, _stopwatchEntireProgram.elapsed.inSeconds);
                                await trainingProgramService.addCompletedProgram(uid, widget.program);
                                _showCompletionDialog();
                                _cancelExistingTimers();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // Make the button background transparent
                              shadowColor: Colors.transparent, // Remove the shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Match the border radius of the container
                              ),
                              elevation: 0, // Remove elevation
                            ),
                            child: const Text(
                              "Next Exercise",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Set text color to white
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
