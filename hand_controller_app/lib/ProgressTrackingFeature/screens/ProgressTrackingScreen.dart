import 'package:flutter/material.dart';
import 'package:hand_controller_app/ProgressTrackingFeature/services/PdfService.dart';
import 'package:hand_controller_app/ProgressTrackingFeature/widgets/LastMonthTotalNumberByCategoryPieChart.dart';
import 'package:hand_controller_app/ProgressTrackingFeature/widgets/FullProgramContainerWidget.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/CreateTrainingProgramScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/services/TrainingProgramService.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import 'package:hand_controller_app/core/widgets/LoadingWidget.dart';
import '../../AuthFeature/models/Doctor.dart';
import '../../AuthFeature/models/Patient.dart';
import '../../AuthFeature/models/User.dart';
import '../../AuthFeature/services/AuthService.dart';
import '../../AuthFeature/services/UserService.dart';
import '../../AlertDialogs/ExitDialogWidget.dart';
import '../../GlobalThemeData.dart';
import '../../ProfileFeature/models/Consultation.dart';
import '../../ProfileFeature/models/Rating.dart';
import '../../ProfileFeature/services/ConsultationService.dart';
import '../../ProfileFeature/services/RatingService.dart';
import '../../TrainingProgramsFeature/models/TrainingProgram.dart';
import '../../core/widgets/CustomDrawer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/LastWeekTotalNumberLineChart.dart';
import '../widgets/TrainingDurationStackedBarChart.dart';
import 'AllCompletedTrainingProgramsScreen.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  _ProgressTrackingScreenState createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  final UserService userService = UserService();
  final AuthService authService = AuthService();
  final PdfService pdfService = PdfService();
  final TrainingProgramService trainingProgramService = TrainingProgramService();

  final PageController _pageController = PageController(viewportFraction: 1);

  List<TrainingProgram> completedPrograms = [];
  List<TrainingProgram> favoritePrograms = [];
  List<TrainingProgram> createdPrograms = [];
  String _sortBy = 'Date';
  bool _ascending = false;

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

  @override
  void initState() {
    super.initState();
    _fetchUserDataFuture = fetchUserData();
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

          List<Consultation> consultationsLocal = await consultationService.getConsultationsByPatientIdAndDoctorId(
            uid,
            userData['doctorId'] as String,
          );
          consultations = consultationsLocal;

          completedPrograms = await trainingProgramService.getCompletedPrograms(uid);
          favoritePrograms = await trainingProgramService.getFavoriteTrainingPrograms(uid);

          Map<String, dynamic>? assignedDoctorData = await userService.getUserData(userData['doctorId'] as String);
          List<Rating> ratingsLocal = await ratingService.getRatingsByDoctorId(userData['doctorId'] as String);

          if (assignedDoctorData != null) {
            assignedDoctor = Doctor.fromMap(assignedDoctorData);
            ratings = ratingsLocal;
          }
        } else if (role == 'Doctor') {
          doctor = Doctor.fromMap(userData);
          user = doctor;
          createdPrograms = await trainingProgramService.getAllTrainingProgramsCreatedByDoctorId(uid);
          print(createdPrograms);
        }
      } else {
        debugPrint('No user data found.');
      }
    } else {
      debugPrint('No UID found in SharedPreferences.');
    }
  }

  void _sortPrograms() {
    completedPrograms.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'Name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'Duration':
          comparison = a.duration.compareTo(b.duration);
          break;
        case 'Date':
        default:
          comparison = a.date.compareTo(b.date);
      }
      return _ascending ? comparison : -comparison;
    });
  }

  void _handleFavoriteChanged(String programId, bool isNowFavorite) {
    setState(() {
      if (isNowFavorite) {
        favoritePrograms.add(completedPrograms.firstWhere((p) => p.trainingProgramId == programId));
      } else {
        favoritePrograms.removeWhere((p) => p.trainingProgramId == programId);
      }
    });
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

            // If data is available and fetched
            if (snapshot.connectionState == ConnectionState.done && user != null) {
              return Scaffold(
                drawer: CustomDrawer(
                  user: user,
                  selectedTile: 'Program Management',
                ),
                body: role == 'Patient' ? progressTrackingContentPatientWidget() : progressTrackingContentDoctorWidget(),
              );
            }

            return const Center(child: Text('No user data available.'));
          },
        ),
      ),
    );
  }

  Widget progressTrackingContentPatientWidget() {
    return Stack(
      children: [
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
            AppBarWidget(),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Charts to visualize your progress',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: PageView.builder(
                                physics: const BouncingScrollPhysics(),
                                controller: _pageController,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  return _buildChartCarouselItem(index);
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            SmoothPageIndicator(
                              controller: _pageController,
                              count: 3,
                              effect: ExpandingDotsEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                activeDotColor: Colors.white,
                                dotColor: Colors.white.withOpacity(0.4), // Inactive dots
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
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
                                offset: const Offset(0, 0),
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
                              pdfService.generateAndSavePDF(user!.name, completedPrograms);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cloud_download, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text(
                                  'Download Reports',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Training Programs Completed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: completedPrograms.isNotEmpty
                            ? Column(
                          children: [
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: completedPrograms.length > 5
                                  ? 5
                                  : completedPrograms.length,
                              itemBuilder: (context, index) {
                                final program = completedPrograms[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: FullProgramContainerWidget(
                                    user: user,
                                    favoriteTrainingPrograms: favoritePrograms,
                                    program: program,
                                    title: program.name,
                                    date:
                                    'Done in ${program.date.day} / ${program.date.month} / ${program.date.year}',
                                    subtitle:
                                    '${program.duration} MINS  ●  ${program.exercises.length} EXERCISES',
                                    isDone: true,
                                    difficulty: program.category,
                                    onFavoriteChanged: _handleFavoriteChanged,
                                  ),
                                );
                              },
                            ),
                            if (completedPrograms.length > 5)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                                        offset: const Offset(0, 0),
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AllCompletedTrainingProgramsScreen(
                                                  user: user,
                                                  favoritePrograms: favoritePrograms,
                                                  completedPrograms: completedPrograms,
                                                onFavoriteChanged: _handleFavoriteChanged,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.list, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Show All Training Programs',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                            : Center(
                          child: const Text(
                            '0 training programs completed',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCarouselItem(int index) {
    switch (index) {
      case 0:
        return LastMonthTotalNumberByCategoryPieChart(
            completedPrograms: completedPrograms);
      case 1:
        return LastWeekTotalNumberLineChart(
            completedPrograms: completedPrograms);
      case 2:
        return TrainingDurationStackedBarChart(
            completedPrograms: completedPrograms);
      default:
        return Container();
    }
  }

  Widget progressTrackingContentDoctorWidget() {
    return Stack(
      children: [
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
            AppBarWidget(),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Programs created:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
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
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CreateTrainingProgramScreen()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0, // Remove elevation
                                    ),
                                    child: const Text(
                                      "+ Add Program",
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
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: createdPrograms.length,
                          itemBuilder: (context, index) {
                            final program = createdPrograms[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: FullProgramContainerWidget(
                                user: user,
                                favoriteTrainingPrograms: favoritePrograms,
                                program: program,
                                title: program.name,
                                isDone: false,
                                date:
                                'Done in ${program.date.day} / ${program.date.month} / ${program.date.year}',
                                subtitle:
                                '${program.duration} MINS  ●  ${program.exercises.length} EXERCISES',
                                difficulty: program.category,
                                onFavoriteChanged: _handleFavoriteChanged,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
