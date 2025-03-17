import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/screens/SignInScreen.dart';
import 'package:hand_controller_app/AuthFeature/services/AuthService.dart';
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final UserService userService = UserService();
  final AuthService authService = AuthService();

  final PageController _pageController = PageController(viewportFraction: 1);

  List<TrainingProgram> completedPrograms = [];
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

          Map<String, dynamic>? assignedDoctorData = await userService.getUserData(userData['doctorId'] as String);
          List<Rating> ratingsLocal = await ratingService.getRatingsByDoctorId(userData['doctorId'] as String);

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
                  name: user!.name,
                  email: user!.email,
                  selectedTile: 'Settings',
                ),
                body: settingsContentWidget(),
              );
            }

            return const Center(child: Text('No user data available.'));
          },
        ),
      ),
    );
  }

  Widget settingsContentWidget() {
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
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await authService.deleteAccount();

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => SignInScreen()),
                                    (Route<dynamic> route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Delete Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Add more settings options here
                        Text(
                          'Settings Page content goes here',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
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
