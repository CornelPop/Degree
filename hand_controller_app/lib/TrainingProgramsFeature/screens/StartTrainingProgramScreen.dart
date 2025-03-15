import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/services/UserService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/TrainingProgramScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/widgets/CountdownTimerWidget.dart';

import '../../GlobalThemeData.dart';
import '../../core/widgets/AppBarWidget.dart';
import '../models/TrainingProgram.dart';

class StartTrainingProgramScreen extends StatefulWidget {
  final TrainingProgram program;

  StartTrainingProgramScreen({Key? key, required this.program}) : super(key: key);

  @override
  _StartTrainingProgramScreenState createState() => _StartTrainingProgramScreenState();
}

class _StartTrainingProgramScreenState extends State<StartTrainingProgramScreen> with TickerProviderStateMixin {
  Timer? _countdownTimer;
  final Stopwatch _stopwatchEntireProgram = Stopwatch();
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentTime = 5;
  int _currentExerciseIndex = -1;
  bool _isExerciseActive = false;

  final UserService userService = UserService();
  int numberBeginnerExercises = 0;
  int numberIntermediateExercises = 0;
  int numberDifficultExercises = 0;
  int timeSpentInWorkouts = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);
    _startCountdown();
  }

  @override
  void dispose() {
    _cancelExistingTimer();
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
    _cancelExistingTimer();
    _animationController.reset();
    _animationController.forward();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime--;
        if (_currentTime == 0) {
          _cancelExistingTimer();
          _startExercise();
        }
      });
    });
  }

  void _cancelExistingTimer() {
    _countdownTimer?.cancel();
  }

  void _startExercise() {
    if (_isExerciseActive) return;
    _isExerciseActive = true;

    setState(() {
      _currentExerciseIndex++;
      _currentTime = 5;
    });

    _animationController.reset();
    _animationController.forward();

    if (_currentExerciseIndex == 0) {
      _startEntireProgramStopWatch();
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime--;
        if (_currentTime == 0) {
          _cancelExistingTimer();
          _isExerciseActive = false;

          if (_currentExerciseIndex < widget.program.exercises.length - 1) {
            _startExercise();
          } else {
            _endEntireProgramStopWatch();
            _updateExerciseCounter(widget.program.category, _stopwatchEntireProgram.elapsed.inSeconds);
            _showCompletionDialog();
          }
        }
      });
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Program Completed"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        content: const Text("Congratulations! You have completed the program."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => TrainingProgramScreen()),
                    (Route<dynamic> route) => false,
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateExerciseCounter(String category, int? timeSpent) async {
    String? uid = await userService.getUserUid();
    if (uid != null) {
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
  }

  Future<void> _addTrainingProgramToCompleted(TrainingProgram trainingProgram) async {
    String? uid = await userService.getUserUid();
    if (uid != null) {
      userService.addCompletedProgram(uid, trainingProgram);
    }
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
                            onPressed: () {
                              _cancelExistingTimer();
                              if (_currentExerciseIndex < widget.program.exercises.length - 1) {
                                _isExerciseActive = false;
                                _startExercise();
                              } else {
                                _updateExerciseCounter(widget.program.category, _stopwatchEntireProgram.elapsed.inSeconds);
                                _addTrainingProgramToCompleted(widget.program);
                                _showCompletionDialog();
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
