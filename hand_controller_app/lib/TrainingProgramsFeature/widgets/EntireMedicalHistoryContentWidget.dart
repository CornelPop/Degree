import 'package:flutter/material.dart';
import 'package:hand_controller_app/ProfileFeature/screens/ShowAllDoctorsOrTherapistsScreen.dart';
import 'package:hand_controller_app/ProfileFeature/models/Rating.dart';
import 'package:hand_controller_app/ProfileFeature/screens/ProfileScreen.dart';
import 'package:hand_controller_app/ProfileFeature/services/ConsultationService.dart';
import 'package:hand_controller_app/ProfileFeature/services/PdfProfileService.dart';
import 'package:hand_controller_app/ProfileFeature/services/RatingService.dart';
import 'package:hand_controller_app/ProfileFeature/widgets/DoneMedicalHistoryContainer.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/ConsultationDetailsScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/EntireMedicalHistoryScreen.dart';
import '../../AuthFeature/models/Patient.dart';
import '../../AuthFeature/services/AuthService.dart';

import '../../AuthFeature/services/UserService.dart';
import '../../GlobalThemeData.dart';
import '../../ProfileFeature/models/Consultation.dart';

class EntireMedicalHistoryContentWidget extends StatefulWidget {
  const EntireMedicalHistoryContentWidget(
      {super.key,
      required this.userId,
      required this.consultations,
      required this.patient});

  final String userId;
  final List<Consultation> consultations;
  final Patient patient;

  @override
  _EntireMedicalHistoryContentWidgetState createState() =>
      _EntireMedicalHistoryContentWidgetState();
}

class _EntireMedicalHistoryContentWidgetState
    extends State<EntireMedicalHistoryContentWidget> {
  final PdfProfileService pdfProfileService = PdfProfileService();
  final ConsultationService consultationService = ConsultationService();
  List<bool> _isExpandedList = [];

  @override
  void initState() {
    super.initState();
    _isExpandedList =
        List.generate(widget.consultations.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Patient's information",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                decoration: BoxDecoration(
                  color: CustomTheme.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        widget.patient.name,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      const Text(
                        'Age:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.patient.name,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      const Text(
                        'Name:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.patient.name,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Medical History',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
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
                                        ConsultationDetailsScreen(
                                          patient: widget.patient,
                                          doctorId: widget.userId,
                                          consultation: Consultation(
                                            patientId: 'dummy_patient_id',
                                            doctorId: widget.userId,
                                            title: '',
                                            consultationId: '',
                                            treatmentPlan: '',
                                            notes: '',
                                            date: DateTime.now(), location: '',
                                          ),
                                          create: true,
                                        )));
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
                            "+ Add consultation",
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: widget.consultations.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.consultations.length,
                      itemBuilder: (context, index) {
                        final consultation = widget.consultations[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: CustomTheme.accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Theme(
                            data: ThemeData().copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              backgroundColor: Colors.transparent,
                              onExpansionChanged: (bool expanded) {
                                setState(() {
                                  _isExpandedList[index] = expanded;
                                });
                              },
                              title: Text(
                                consultation.title,
                                style: const TextStyle(color: Colors.white),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Date and time:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          consultation.date.toLocal().toString(),
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
                                          consultation.treatmentPlan,
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
                                          consultation.notes,
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 14),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
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
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 20,
                                                    offset: Offset(0, 0),
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: ElevatedButton(
                                                  onPressed: () async {
                                                    pdfProfileService
                                                        .generateAndSavePDFSpecificConsultation(
                                                      widget.patient.name,
                                                      consultation,
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    elevation:
                                                        0, // Remove elevation
                                                  ),
                                                  child:
                                                      const Icon(Icons.download, color: Colors.white, size: 20)),
                                            ),
                                            Container(
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
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 20,
                                                    offset: Offset(0, 0),
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ConsultationDetailsScreen(
                                                                  patient: widget
                                                                      .patient,
                                                                  doctorId: widget
                                                                      .userId,
                                                                  create: false,
                                                                  consultation: consultation,
                                                                )));
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    elevation:
                                                        0, // Remove elevation
                                                  ),
                                                  child: const Icon(Icons.edit, color: Colors.white, size: 20)),
                                            ),
                                            Container(
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
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 20,
                                                    offset: Offset(0, 0),
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: ElevatedButton(
                                                  onPressed: () async {
                                                    consultationService
                                                        .deleteConsultation(
                                                            consultation.consultationId);
                                                    setState(() {
                                                      widget.consultations
                                                          .remove(consultation);
                                                    });
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    elevation:
                                                        0, // Remove elevation
                                                  ),
                                                  child:
                                                      const Icon(Icons.delete, color: Colors.white, size: 20,)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No consultations available.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
