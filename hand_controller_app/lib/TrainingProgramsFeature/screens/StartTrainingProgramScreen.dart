import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/services/UserService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/TrainingProgramScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/widgets/ProgressBarWidget.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../../AuthFeature/models/User.dart';
import '../../GlobalThemeData.dart';
import '../../core/widgets/AppBarWidget.dart';
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
  Timer? _countdownTimer;
  Timer? _flexReadingTimer;
  final Stopwatch _stopwatchEntireProgram = Stopwatch();

  late AnimationController _animationController;
  late Animation<double> _animation;

  int _currentTime = 30;
  int _currentExerciseIndex = -1;
  bool _isExerciseActive = false;
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
      duration: const Duration(seconds: 30),
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

  // New method for the preparation countdown
  void _startPreparationCountdown() {
    _cancelExistingTimers();
    setState(() {
      _isPreparing = true;
      _currentTime = 30; // 30 seconds to get ready
    });

    _animationController.reset();
    _animationController.duration = const Duration(seconds: 30);
    _animationController.forward();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime--;
          if (_currentTime == 0) {
            _cancelExistingTimers();
            _startExercise();
          }
        });
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

  void _startExercise() {
    if (_isExerciseActive) return;
    _isExerciseActive = true;

    setState(() {
      _isPreparing = false;
      _currentExerciseIndex++;
      _currentTime = 30; // Changed to 30 seconds per exercise
    });

    // Reset animation with new duration
    _animationController.duration = const Duration(seconds: 30);
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

            Map<String, int> userValues = Map<String, int>.from(currentFlexValues);

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
                      percentage: precisions['overallPrecision'] ?? 0,
                      text: 'Accuracy for this program',
                      rounded: true,
                    ),
                    const SizedBox(height: 10),
                    ProgressBarWidget(
                      percentage: precisions['fingerPrecisions']['Thumb'] ?? 0,
                      text: 'Thumb',
                      rounded: false,
                    ),
                    ProgressBarWidget(
                      percentage: precisions['fingerPrecisions']['Index'] ?? 0,
                      text: 'Index',
                      rounded: false,
                    ),
                    ProgressBarWidget(
                      percentage: precisions['fingerPrecisions']['Middle'] ?? 0,
                      text: 'Middle',
                      rounded: false,
                    ),
                    ProgressBarWidget(
                      percentage: precisions['fingerPrecisions']['Ring'] ?? 0,
                      text: 'Ring',
                      rounded: false,
                    ),
                    ProgressBarWidget(
                      percentage: precisions['fingerPrecisions']['Pinky'] ?? 0,
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
                  _updateExerciseCounter(widget.program.category, _stopwatchEntireProgram.elapsed.inSeconds);
                  await trainingProgramService.addCompletedProgram(uid, widget.program);
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
          )
        ],
      ),
    );
  }
}