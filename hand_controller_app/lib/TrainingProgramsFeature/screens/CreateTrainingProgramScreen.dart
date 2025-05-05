import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hand_controller_app/AlertDialogs/ErrorDialogWidget.dart';
import 'package:hand_controller_app/AuthFeature/screens/SignInScreen.dart';
import 'package:hand_controller_app/AuthFeature/services/AuthService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/models/Exercise.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/ReviewTrainingProgramScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/services/ExerciseService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/services/TrainingProgramService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/widgets/ExerciseTileWidget.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import 'package:hand_controller_app/core/widgets/LoadingWidget.dart';
import '../../AuthFeature/models/Doctor.dart';
import '../../AuthFeature/models/Patient.dart';
import '../../AuthFeature/models/User.dart';
import '../../AuthFeature/services/UserService.dart';
import '../../AlertDialogs/ExitDialogWidget.dart';
import '../../GlobalThemeData.dart';
import '../../ProfileFeature/models/Consultation.dart';
import '../../ProfileFeature/models/Rating.dart';
import '../../ProfileFeature/services/ConsultationService.dart';
import '../../ProfileFeature/services/RatingService.dart';
import '../../TrainingProgramsFeature/models/TrainingProgram.dart';
import '../../core/widgets/CustomDrawer.dart';
import '../models/MockDataTrainingPrograms.dart';

class CreateTrainingProgramScreen extends StatefulWidget {
  const CreateTrainingProgramScreen({Key? key}) : super(key: key);

  @override
  CreateTrainingProgramScreenState createState() =>
      CreateTrainingProgramScreenState();
}

class CreateTrainingProgramScreenState
    extends State<CreateTrainingProgramScreen> {
  final UserService userService = UserService();
  final AuthService authService = AuthService();
  final TrainingProgramService trainingProgramService =
      TrainingProgramService();
  final ExerciseService exerciseService = ExerciseService();

  TextEditingController searchController = TextEditingController();

  final List<int> _items = List<int>.generate(50, (int index) => index);
  List<Exercise> exercises = getExercises();

  late List<Exercise> filteredExercises;

  List<TrainingProgram> completedPrograms = [];

  List<Exercise> trainingProgramExercises = [];

  late Future<void> _fetchUserDataFuture;

  final ConsultationService consultationService = ConsultationService();
  final RatingService ratingService = RatingService();

  String? role;

  List<Consultation> consultations = [];
  List<Rating> ratings = [];

  Patient? patient;
  Doctor? assignedDoctor;
  Doctor? doctor;

  User? user;

  String _searchedString = '';

  void _filterBySearchField(String query) {
    setState(() {
      filteredExercises = exercises
          .where((exercise) =>
              exercise.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDataFuture = fetchUserData();
    filteredExercises = List.from(exercises);
  }

  Future<void> fetchUserData() async {
    String? uid = await userService.getUserUid();
    if (uid != null) {
      Map<String, dynamic>? userData = await userService.getUserData(uid);
      if (userData != null) {
        role = userData['role'];

        if (role == 'Patient') {
          patient = Patient.fromMap(userData);
          user = patient;

          List<Consultation> consultationsLocal =
              await consultationService.getConsultationsByPatientIdAndDoctorId(
            uid,
            userData['doctorId'] as String,
          );
          consultations = consultationsLocal;

          Map<String, dynamic>? assignedDoctorData =
              await userService.getUserData(userData['doctorId'] as String);
          List<Rating> ratingsLocal = await ratingService
              .getRatingsByDoctorId(userData['doctorId'] as String);

          if (assignedDoctorData != null) {
            assignedDoctor = Doctor.fromMap(assignedDoctorData);
            ratings = ratingsLocal;
          }
        } else if (role == 'Doctor') {
          doctor = Doctor.fromMap(userData);
          user = doctor;
        }
      } else {
        debugPrint('No user data found.');
      }
    } else {
      debugPrint('No UID found in SharedPreferences.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await ExitDialog.showExitDialog(context);
      },
      child: Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (trainingProgramExercises.length < 5) {
                      ErrorDialogWidget(
                          message: 'You need to add at least 5 exercises. Until now you have ${trainingProgramExercises.length}:\n'
                              '${trainingProgramExercises.map((e) => e.name).join("\n")}'
                      ).showErrorDialog(context);

                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewTrainingProgramScreen(
                            trainingProgramExercises: trainingProgramExercises,
                            userId: user!.uid,
                            isEdit: false,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Review Program',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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

            // If data is available and fetched
            if (snapshot.connectionState == ConnectionState.done &&
                user != null) {
              return Scaffold(
                body: createTrainingProgramWidget(),
              );
            }

            return const Center(child: Text('No user data available.'));
          },
        ),
      ),
    );
  }

  Widget createTrainingProgramWidget() {
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
                      "Exercises you can add:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CustomTheme.accentColor4,
                          CustomTheme.accentColor2
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          blurRadius: 20, // Blur radius
                          offset: Offset(0, 0), // Offset of the shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search exercises...',
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) {
                        _searchedString = value;
                        _filterBySearchField(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        color: Colors.white.withOpacity(0.1),
                        key: Key('$index'),
                        child: ExerciseTileWidget(
                          exercise: filteredExercises[index],
                          onAddExercise: (exercise, repetitions) {
                            setState(() {
                              trainingProgramExercises.add(
                                Exercise(
                                  exerciseId: exercise.exerciseId,
                                  name: exercise.name,
                                  description: exercise.description,
                                  numberOfTimes: repetitions,
                                  targetValues: exercise.targetValues,
                                  animationPath: exercise.animationPath
                                ),
                              );
                            });
                            print(
                                'Added ${exercise.name} with $repetitions reps!');
                            print(trainingProgramExercises);
                          },
                        ),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
