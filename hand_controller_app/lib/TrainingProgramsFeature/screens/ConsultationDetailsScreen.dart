import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hand_controller_app/AlertDialogs/ErrorDialogWidget.dart';
import 'package:hand_controller_app/AuthFeature/models/Patient.dart';
import 'package:hand_controller_app/AuthFeature/services/SharedPrefService.dart';
import 'package:hand_controller_app/ProfileFeature/models/Consultation.dart';
import 'package:hand_controller_app/ProfileFeature/services/ConsultationService.dart';
import 'package:hand_controller_app/ProfileFeature/services/RatingService.dart';
import 'package:hand_controller_app/ProfileFeature/widgets/ProfileDoctorContentWidget.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/EntireMedicalHistoryScreen.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import '../../AuthFeature/services/AuthService.dart';
import '../../AuthFeature/services/UserService.dart';
import '../../AlertDialogs/ExitDialogWidget.dart';
import '../../GlobalThemeData.dart';
import '../widgets/EntireMedicalHistoryContentWidget.dart';

class ConsultationDetailsScreen extends StatefulWidget {
  final String doctorId;
  final Patient patient;
  final bool create;
  final Consultation consultation;

  const ConsultationDetailsScreen(
      {super.key,
      required this.patient,
      required this.doctorId,
      required this.create,
      required this.consultation});

  @override
  _ConsultationDetailsScreenState createState() =>
      _ConsultationDetailsScreenState();
}

class _ConsultationDetailsScreenState extends State<ConsultationDetailsScreen> {
  final ConsultationService consultationService = ConsultationService();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController treatmentPlanController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.create == false) {
      dateController.text = widget.consultation.date.toLocal().toString();
      titleController.text = widget.consultation.title;
      treatmentPlanController.text = widget.consultation.treatmentPlan;
      notesController.text = widget.consultation.notes;
      locationController.text = widget.consultation.location;
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
                  child: Container(
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
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              widget.create == true
                                  ? const Text(
                                      'Create consultation',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: CustomTheme.secondaryColor,
                                      ),
                                    )
                                  : const Text(
                                      'Edit consultation',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: CustomTheme.secondaryColor,
                                      ),
                                    ),
                              SizedBox(height: 30),
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
                                      color: Colors.black.withOpacity(0.2),
                                      // Shadow color
                                      blurRadius: 20,
                                      // Blur radius
                                      offset:
                                          Offset(0, 0), // Offset of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    labelText: widget.patient.name,
                                    prefixIcon: Icon(Icons.account_circle,
                                        color: Colors.white),
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 20),
                              InkWell(
                                onTap: () async {
                                  _selectDateAndTime(context);
                                },
                                child: Container(
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
                                        color: Colors.black.withOpacity(0.2),
                                        // Shadow color
                                        blurRadius: 20,
                                        // Blur radius
                                        offset: Offset(
                                            0, 0), // Offset of the shadow
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: TextFormField(
                                    enabled: false,
                                    readOnly: true,
                                    controller: dateController,
                                    decoration: InputDecoration(
                                      labelText: 'Date and time',
                                      prefixIcon: Icon(Icons.calendar_month,
                                          color: Colors.white),
                                      border: InputBorder.none,
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                    ),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
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
                                      color: Colors.black.withOpacity(0.2),
                                      // Shadow color
                                      blurRadius: 20,
                                      // Blur radius
                                      offset:
                                          Offset(0, 0), // Offset of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    labelText: 'Title',
                                    prefixIcon:
                                        Icon(Icons.title, color: Colors.white),
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 20),
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
                                      color: Colors.black.withOpacity(0.2),
                                      // Shadow color
                                      blurRadius: 20,
                                      // Blur radius
                                      offset:
                                          Offset(0, 0), // Offset of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: locationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Location',
                                    prefixIcon:
                                        Icon(Icons.location_on, color: Colors.white),
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 140,
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
                                      color: Colors.black.withOpacity(0.2),
                                      // Shadow color
                                      blurRadius: 20,
                                      // Blur radius
                                      offset:
                                          Offset(0, 0), // Offset of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  maxLines: 5,
                                  controller: treatmentPlanController,
                                  decoration: InputDecoration(
                                    labelText: 'Treatment plan',
                                    prefixIcon: Icon(Icons.content_paste,
                                        color: Colors.white),
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 140,
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
                                      color: Colors.black.withOpacity(0.2),
                                      // Shadow color
                                      blurRadius: 20,
                                      // Blur radius
                                      offset:
                                          Offset(0, 0), // Offset of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  maxLines: 5,
                                  controller: notesController,
                                  decoration: InputDecoration(
                                    labelText: 'Notes',
                                    prefixIcon:
                                        Icon(Icons.notes, color: Colors.white),
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
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
                                      color: Colors.black.withOpacity(0.2),
                                      // Shadow color
                                      blurRadius: 20,
                                      // Blur radius
                                      offset:
                                          Offset(0, 0), // Offset of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    print('object');

                                    String errors = '';
                                    if (dateController.text.isEmpty) {
                                      errors += 'Please enter a date\n';
                                    }

                                    if (titleController.text.isEmpty) {
                                      errors += 'Please enter a title\n';
                                    }

                                    if (treatmentPlanController.text.isEmpty) {
                                      errors +=
                                          'Please enter a Treatment Plan\n';
                                    }

                                    if (notesController.text.isEmpty) {
                                      errors += 'Please enter some notes\n';
                                    }

                                    if (errors.isNotEmpty) {
                                      ErrorDialogWidget(message: errors.trim())
                                          .showErrorDialog(context);
                                      return;
                                    } else {
                                      if (widget.create == true) {
                                        consultationService.addConsultation(
                                            Consultation(
                                                consultationId: '',
                                                doctorId: widget.doctorId,
                                                patientId: widget.patient.uid,
                                                date: DateTime.parse(dateController.text),
                                                title: titleController.text,
                                                notes: notesController.text,
                                                treatmentPlan: treatmentPlanController.text,
                                                location: ''));
                                      } else {
                                        widget.consultation.title = titleController.text;
                                        widget.consultation.date = dateController.text as DateTime;
                                        widget.consultation.treatmentPlan = treatmentPlanController.text;
                                        widget.consultation.notes = notesController.text;
                                        //widget.consultation.location =
                                        consultationService.updateConsultation(widget.consultation);
                                      }
                                    }

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EntireMedicalHistoryScreen(
                                                patient: widget.patient),
                                      ),
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
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      ))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateAndTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          dateController.text = selectedDateTime.toString();
        });
      }
    }
  }
}
