import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/models/Patient.dart';
import 'package:hand_controller_app/AuthFeature/services/SharedPrefService.dart';
import 'package:hand_controller_app/ProfileFeature/models/MedicalHistory.dart';
import 'package:hand_controller_app/ProfileFeature/services/ConsultationService.dart';
import 'package:hand_controller_app/ProfileFeature/services/RatingService.dart';
import 'package:hand_controller_app/ProfileFeature/widgets/ProfileDoctorContentWidget.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import '../../AuthFeature/services/AuthService.dart';
import '../../AuthFeature/services/UserService.dart';
import '../../AlertDialogs/ExitDialogWidget.dart';
import '../../GlobalThemeData.dart';
import '../widgets/EntireMedicalHistoryContentWidget.dart';

class EntireMedicalHistoryScreen extends StatefulWidget {
  final Patient patient;

  const EntireMedicalHistoryScreen({super.key, required this.patient});

  @override
  _EntireMedicalHistoryScreenState createState() =>
      _EntireMedicalHistoryScreenState();
}

class _EntireMedicalHistoryScreenState
    extends State<EntireMedicalHistoryScreen> {
  final UserService userService = UserService();
  final AuthService authService = AuthService();
  final ConsultationService consultationService = ConsultationService();
  final RatingService ratingService = RatingService();

  String userId = '';
  String name = '';
  String email = '';
  String role = '';

  List<Consultation> consultations = [];

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
      List<Consultation> consultationsLocal =
          await consultationService.getConsultationsByPatientId(widget.patient.uid);
      if (userData != null) {
        setState(() {
          userId = uid;
          name = userData['name'] as String;
          email = userData['email'] as String;
          role = userData['role'] as String;
          consultations = consultationsLocal;
        });
      } else {
        print('No user data found.');
      }
    } else {
      print('No UID found in SharedPreferences.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
              const AppBarWidget(leadingIcon: Icons.arrow_back,),
              Expanded(
                child: FutureBuilder(
                  future: _fetchUserDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
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
                          child: const Center(
                              child: CircularProgressIndicator()));
                    } else {
                      return EntireMedicalHistoryContentWidget(
                        userId: userId,
                        consultations: consultations,
                        patient: widget.patient,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
