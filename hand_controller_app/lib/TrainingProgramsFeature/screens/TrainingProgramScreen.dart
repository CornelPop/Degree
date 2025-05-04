import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/services/AuthService.dart';
import 'package:hand_controller_app/AuthFeature/services/UserService.dart';
import 'package:hand_controller_app/ProfileFeature/services/ConsultationService.dart';
import 'package:hand_controller_app/ProgressTrackingFeature/screens/ProgressTrackingScreen.dart';
import 'package:hand_controller_app/ProgressTrackingFeature/widgets/FullProgramContainerWidget.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/services/TrainingProgramService.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import 'package:hand_controller_app/core/widgets/CustomDrawer.dart';
import '../../AlertDialogs/ExitDialogWidget.dart';
import '../../AuthFeature/models/Doctor.dart';
import '../../AuthFeature/models/Patient.dart';
import '../../AuthFeature/models/User.dart';
import '../../GlobalThemeData.dart';
import '../../ProfileFeature/models/Consultation.dart';
import '../../core/widgets/LoadingWidget.dart';
import '../models/TrainingProgram.dart';
import '../widgets/ProgramContainerWidget.dart';

import 'AllTrainingProgramsScreen.dart';

class TrainingProgramScreen extends StatefulWidget {
  const TrainingProgramScreen({Key? key}) : super(key: key);

  @override
  _TrainingProgramScreenState createState() => _TrainingProgramScreenState();
}

class _TrainingProgramScreenState extends State<TrainingProgramScreen> {
  final UserService userService = UserService();
  final AuthService authService = AuthService();
  final TrainingProgramService trainingProgramService =
      TrainingProgramService();
  final ConsultationService consultationService = ConsultationService();

  String name = '';
  String email = '';
  String role = '';

  late double screenWidth;
  late double screenHeight;
  late double buttonWidth;
  late double buttonHeight;
  late double containerHeight;

  int numberBeginnerExercises = 0;
  int numberIntermediateExercises = 0;
  int numberDifficultExercises = 0;

  int numberBeginnerProgramsCreated = 0;
  int numberIntermediateProgramsCreated = 0;
  int numberDifficultProgramsCreated = 0;

  int timeSpentInWorkouts = 0;
  int totalCompletions = 0;
  double accuracyOfExercises = 0.0;

  late Future<void> _fetchUserDataFuture;

  bool _isFilterTileExpended = false;

  late List<Patient> patients;
  List<Patient> filteredPatients = [];
  List<bool> _isExpandedList = [];
  TextEditingController searchController = TextEditingController();

  late String userId;

  List<TrainingProgram> favoriteTrainingPrograms = [];
  List<TrainingProgram> trainingPrograms = [];
  List<TrainingProgram> beginnerTrainingPrograms = [];
  List<TrainingProgram> intermediateTrainingPrograms = [];
  List<TrainingProgram> difficultTrainingPrograms = [];

  Consultation? nextConsultation;
  Patient? nextPatient;
  bool isExpanded = false;

  TrainingProgram? lastTrainingProgramCreated;

  Patient? patient;
  Doctor? assignedDoctor;
  Doctor? doctor;

  User? user;

  @override
  void initState() {
    super.initState();
    _fetchUserDataFuture = fetchUserData();
  }

  void _handleFavoriteChanged(String programId, bool isNowFavorite) {
    setState(() {
      if (isNowFavorite) {
        favoriteTrainingPrograms.add(trainingPrograms
            .firstWhere((p) => p.trainingProgramId == programId));
      } else {
        favoriteTrainingPrograms
            .removeWhere((p) => p.trainingProgramId == programId);
      }
    });
  }

  Future<void> fetchUserData() async {
    String? uid = await userService.getUserUid();
    if (uid == null) {
      debugPrint('No UID found in SharedPreferences.');
      return;
    }

    Map<String, dynamic>? userData = await userService.getUserData(uid);
    if (userData == null) {
      debugPrint('No user data found.');
      return;
    }

    role = userData['role'] as String;
    name = userData['name'] as String;
    email = userData['email'] as String;

    if (role == 'Patient') {
      patient = Patient.fromMap(userData);
      user = patient;
      trainingPrograms = await trainingProgramService.getAllTrainingPrograms();
      print(trainingPrograms);
      favoriteTrainingPrograms =
          await trainingProgramService.getFavoriteTrainingPrograms(uid);

      beginnerTrainingPrograms = trainingPrograms
          .where((program) => program.category == 'Beginner')
          .toList();
      intermediateTrainingPrograms = trainingPrograms
          .where((program) => program.category == 'Intermediate')
          .toList();
      difficultTrainingPrograms = trainingPrograms
          .where((program) => program.category == 'Difficult')
          .toList();

      numberBeginnerExercises = userData['numberBeginnerExercises'] as int;
      numberIntermediateExercises =
          userData['numberIntermediateExercises'] as int;
      numberDifficultExercises = userData['numberDifficultExercises'] as int;
      timeSpentInWorkouts = userData['timeSpentInWorkouts'] as int;
      accuracyOfExercises = userData['accuracyOfExercises'] as double;
    } else if (role == 'Doctor') {
        doctor = Doctor.fromMap(userData);
        user = doctor;
        totalCompletions = await trainingProgramService
            .getTotalCompletionsForDoctorPrograms(uid);
        nextConsultation =
            await consultationService.getNextConsultationForDoctor(uid);
        nextPatient = (await userService.getPatientData(nextConsultation!.patientId));
        lastTrainingProgramCreated = await trainingProgramService
            .getLastTrainingProgramCreatedByDoctor(uid);

        numberBeginnerProgramsCreated = await trainingProgramService.countProgramsByDoctorAndCategory(doctorId: uid, category: 'Beginner');
        numberIntermediateProgramsCreated = await trainingProgramService.countProgramsByDoctorAndCategory(doctorId: uid, category: 'Intermediate');
        numberDifficultProgramsCreated = await trainingProgramService.countProgramsByDoctorAndCategory(doctorId: uid, category: 'Difficult');

        userId = uid;
        List<dynamic> patientsLocal =
            await userService.getPatientsByDoctorId(uid);
        patients = patientsLocal.cast<Patient>();
        filteredPatients = patients;
        _isExpandedList = List.generate(patients.length, (_) => false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    buttonWidth = screenWidth * 0.90;
    buttonHeight = screenHeight * 0.08;
    containerHeight = screenHeight * 0.15;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await ExitDialog.showExitDialog(context);
      },
      child: Scaffold(
        body: FutureBuilder(
          future: _fetchUserDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'An error occurred: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.done &&
                user != null) {
              return Scaffold(
                drawer: CustomDrawer(
                  user: user,
                  selectedTile: 'Dashboard',
                ),
                body: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CustomTheme.mainColor2,
                            CustomTheme.mainColor
                          ],
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
                        AppBarWidget(),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CustomTheme.mainColor2,
                                  CustomTheme.mainColor
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: role == 'Patient'
                                ? _buildContentForPatient()
                                : _buildContentForDoctor(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('No user data available.'));
          },
        ),
      ),
    );
  }

  Widget _buildContentForPatient() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Opacity(
                        opacity: 0.7,
                        child: Text(
                          "Hello,",
                          style: TextStyle(fontSize: 40, color: Colors.white),
                        ),
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Container(height: screenHeight * 0.02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Your stats',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              Container(height: screenHeight * 0.01),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: screenHeight * 0.35,
                  //color: Colors.lightBlue,
                  child: Row(
                    children: [
                      // First container with less space
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProgressTrackingScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 8.0, right: 8.0),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.accentColor4,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.insert_chart,
                                            color: Colors.white, size: 40),
                                        Text(
                                          '$accuracyOfExercises',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          'Accuracy',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProgressTrackingScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      right: 8.0, top: 8.0),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.accentColor4,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.timer,
                                            color: Colors.white, size: 40),
                                        Text(
                                          '$timeSpentInWorkouts',
                                          style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          'Time Spent',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProgressTrackingScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 8.0, left: 8.0),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.accentColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.bolt,
                                            color: Colors.blue[900], size: 30),
                                        Opacity(
                                          opacity: 0.3,
                                          child: Icon(Icons.bolt,
                                              color: Colors.blue[900],
                                              size: 30),
                                        ),
                                        Opacity(
                                          opacity: 0.3,
                                          child: Icon(Icons.bolt,
                                              color: Colors.blue[900],
                                              size: 30),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$numberBeginnerExercises',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                'Exercises',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProgressTrackingScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 4.0, left: 8.0, top: 4.0),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.accentColor2,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.bolt,
                                            color: Colors.blue[900], size: 30),
                                        Icon(Icons.bolt,
                                            color: Colors.blue[900], size: 30),
                                        Opacity(
                                          opacity: 0.3,
                                          child: Icon(Icons.bolt,
                                              color: Colors.blue[900],
                                              size: 30),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$numberIntermediateExercises',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              Text('Exercises',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProgressTrackingScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 8.0, top: 8.0),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.accentColor3,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.bolt,
                                            color: Colors.blue[900], size: 30),
                                        Icon(Icons.bolt,
                                            color: Colors.blue[900], size: 30),
                                        Icon(Icons.bolt,
                                            color: Colors.blue[900], size: 30),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$numberDifficultExercises',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                'Exercises',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(height: screenHeight * 0.02), // 2% of the screen height
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Beginner',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              Container(height: screenHeight * 0.01), // 2% of the screen height
              Container(
                alignment: Alignment.centerLeft,
                height: screenHeight * 0.17,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    if (index < 3) {
                      final program = beginnerTrainingPrograms[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 15.0),
                        child: ProgramContainer(
                          favoriteTrainingPrograms: favoriteTrainingPrograms,
                          user: user,
                          program: program,
                          title: program.name,
                          subtitle:
                              '${program.duration} MINS  ●  ${program.exercises.length} EXERCISES',
                          difficulty: program.category,
                          onFavoriteChanged: _handleFavoriteChanged,
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllTrainingProgramsScreen(
                                  user: user,
                                  programs: trainingPrograms,
                                  favoriteTrainingPrograms:
                                      favoriteTrainingPrograms,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: CustomTheme.accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(Icons.more_horiz,
                                  size: 40, color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              Container(height: screenHeight * 0.02), // 2% of the screen height
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Intermediate',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              Container(height: screenHeight * 0.01), // 2% of the screen height
              Container(
                height: screenHeight * 0.17,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    if (index < 3) {
                      final program = intermediateTrainingPrograms[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 15.0),
                        child: ProgramContainer(
                          favoriteTrainingPrograms: favoriteTrainingPrograms,
                          user: user,
                          program: program,
                          title: program.name,
                          subtitle:
                              '${program.duration} MINS  ●  ${program.exercises.length} EXERCISES',
                          difficulty: program.category,
                          onFavoriteChanged: _handleFavoriteChanged,
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllTrainingProgramsScreen(
                                  user: user,
                                  programs: trainingPrograms,
                                  favoriteTrainingPrograms:
                                      favoriteTrainingPrograms,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: CustomTheme.accentColor2,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(Icons.more_horiz,
                                  size: 40, color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              Container(height: screenHeight * 0.02), // 2% of the screen height
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Difficult',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              Container(height: screenHeight * 0.01), // 2% of the screen height
              Container(
                height: screenHeight * 0.17,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    if (index < 3) {
                      final program = difficultTrainingPrograms[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: ProgramContainer(
                          user: user,
                          favoriteTrainingPrograms: favoriteTrainingPrograms,
                          program: program,
                          title: program.name,
                          subtitle:
                              '${program.duration} MINS  ●  ${program.exercises.length} EXERCISES',
                          difficulty: program.category,
                          onFavoriteChanged: _handleFavoriteChanged,
                        ),
                      );
                    } else {
                      // 4th item: "more" icon
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllTrainingProgramsScreen(
                                  user: user,
                                  programs: trainingPrograms,
                                  favoriteTrainingPrograms:
                                      favoriteTrainingPrograms,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: CustomTheme.accentColor3,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(Icons.more_horiz,
                                  size: 40, color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              Container(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentForDoctor() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Opacity(
                          opacity: 0.7,
                          child: Text(
                            "Hello,",
                            style: TextStyle(fontSize: 40, color: Colors.white),
                          ),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Your stats',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: screenHeight * 0.35,
                  //color: Colors.lightBlue,
                  child: Row(
                    children: [
                      // First container with less space
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProgressTrackingScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      right: 8.0),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.accentColor4,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.loop,
                                            color: Colors.white, size: 40),
                                        Text(
                                          '$totalCompletions',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          'Completions',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          'on your',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          'programs',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProgressTrackingScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 8.0, left: 8.0),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.accentColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.bolt,
                                            color: Colors.blue[900], size: 30),
                                        Opacity(
                                          opacity: 0.3,
                                          child: Icon(Icons.bolt,
                                              color: Colors.blue[900],
                                              size: 30),
                                        ),
                                        Opacity(
                                          opacity: 0.3,
                                          child: Icon(Icons.bolt,
                                              color: Colors.blue[900],
                                              size: 30),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$numberBeginnerProgramsCreated',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                'Programs',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                'Created',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProgressTrackingScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 4.0, left: 8.0, top: 4.0),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.accentColor2,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.bolt,
                                            color: Colors.blue[900], size: 30),
                                        Icon(Icons.bolt,
                                            color: Colors.blue[900], size: 30),
                                        Opacity(
                                          opacity: 0.3,
                                          child: Icon(Icons.bolt,
                                              color: Colors.blue[900],
                                              size: 30),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$numberIntermediateProgramsCreated',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                'Programs',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                'Created',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProgressTrackingScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 8.0, top: 8.0),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.accentColor3,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.bolt,
                                            color: Colors.blue[900], size: 30),
                                        Icon(Icons.bolt,
                                            color: Colors.blue[900], size: 30),
                                        Icon(Icons.bolt,
                                            color: Colors.blue[900], size: 30),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$numberDifficultProgramsCreated',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                'Programs',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                'Created',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Next consultation',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              nextConsultation != null
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: CustomTheme.accentColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Theme(
                          data: ThemeData()
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            backgroundColor: Colors.transparent,
                            onExpansionChanged: (bool expanded) {
                              setState(() {
                                isExpanded = expanded;
                              });
                            },
                            title: Text(
                              nextConsultation!.title,
                              style: TextStyle(color: Colors.white),
                            ),
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: CustomTheme.accentColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Name:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          nextPatient!.name,
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 14),
                                        ),
                                        SizedBox(height: 8,),
                                        const Text(
                                          'Date:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          nextConsultation!.date
                                              .toLocal()
                                              .toString(),
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 14),
                                        ),
                                        SizedBox(height: 8),
                                        const Text(
                                          'Plan:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          nextConsultation!.treatmentPlan,
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 14),
                                        ),
                                        SizedBox(height: 8),
                                        const Text(
                                          'Notes:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          nextConsultation!.notes,
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 14),
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      child: Center(
                      child: Text(
                        'No Consultation available.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Last Training Program Created',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              lastTrainingProgramCreated != null
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: FullProgramContainerWidget(
                          program: lastTrainingProgramCreated!,
                          title: lastTrainingProgramCreated!.name,
                          date:
                              'Done in ${lastTrainingProgramCreated!.date.day} / ${lastTrainingProgramCreated!.date.month} / ${lastTrainingProgramCreated!.date.year}',
                          subtitle:
                              '${lastTrainingProgramCreated!.duration} MINS  ●  ${lastTrainingProgramCreated!.exercises.length} EXERCISES',
                          difficulty: lastTrainingProgramCreated!.category,
                          user: user,
                          favoriteTrainingPrograms: favoriteTrainingPrograms,
                          onFavoriteChanged: _handleFavoriteChanged,
                          isDone: false),
                    )
                  : Container(
                      child: Center(
                      child: Text(
                        'No Program available.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
              ),
              SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }
}
