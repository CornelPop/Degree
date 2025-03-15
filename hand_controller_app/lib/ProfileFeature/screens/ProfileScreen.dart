import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/models/Patient.dart';
import 'package:hand_controller_app/AuthFeature/services/SharedPrefService.dart';
import 'package:hand_controller_app/ProfileFeature/models/MedicalHistory.dart';
import 'package:hand_controller_app/ProfileFeature/services/ConsultationService.dart';
import 'package:hand_controller_app/ProfileFeature/services/RatingService.dart';
import 'package:hand_controller_app/ProfileFeature/widgets/ProfileDoctorContentWidget.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import 'package:hand_controller_app/core/widgets/LoadingWidget.dart';
import '../../AuthFeature/models/Doctor.dart';
import '../../AuthFeature/models/User.dart';
import '../../AuthFeature/services/AuthService.dart';
import '../../AuthFeature/services/UserService.dart';
import '../../AlertDialogs/ExitDialogWidget.dart';
import '../../GlobalThemeData.dart';
import '../../core/widgets/CustomDrawer.dart';
import '../models/Rating.dart';
import '../widgets/ProfilePatientContentWidget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService userService = UserService();
  final ConsultationService consultationService = ConsultationService();
  final AuthService authService = AuthService();
  final RatingService ratingService = RatingService();

  String? role;

  List<Consultation> consultations = [];
  List<Rating> ratings = [];

  Patient? patient;
  Doctor? assignedDoctor;
  Doctor? doctor;

  User? user;

  late Future<void> _fetchUserDataFuture;

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
                drawer: CustomDrawer(
                  name: user!.name,
                  email: user!.email,
                  selectedTile: 'Profile',
                ),
                body: _buildProfileContent(),
              );
            }

            return const Center(child: Text('No user data available.'));
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: (role == 'Patient' && patient != null)
                    ? ProfilePatientContentWidget(
                        consultations: consultations,
                        ratings: ratings,
                        patient: patient!,
                        assignedDoctor: assignedDoctor,
                      )
                    : (role == 'Doctor' && doctor != null)
                        ? ProfileDoctorContentWidget(doctor: doctor!)
                        : const Center(
                            child: Text('No profile data available')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
