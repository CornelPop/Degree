import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/models/Patient.dart';
import 'package:hand_controller_app/ProfileFeature/screens/EditProfileScreen.dart';
import 'package:hand_controller_app/ProfileFeature/screens/ShowAllDoctorsOrTherapistsScreen.dart';
import 'package:hand_controller_app/ProfileFeature/models/Rating.dart';
import 'package:hand_controller_app/ProfileFeature/screens/ProfileScreen.dart';
import 'package:hand_controller_app/ProfileFeature/services/PdfProfileService.dart';
import 'package:hand_controller_app/ProfileFeature/services/RatingService.dart';
import 'package:hand_controller_app/core/widgets/CustomSlideActionWidget.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../../AuthFeature/models/Doctor.dart';
import '../../AuthFeature/services/UserService.dart';
import '../../GlobalThemeData.dart';
import '../models/MedicalHistory.dart';

class ProfilePatientContentWidget extends StatefulWidget {
  const ProfilePatientContentWidget(
      {super.key,
      required this.consultations,
      required this.ratings,
      required this.patient,
      required this.assignedDoctor});

  final Patient patient;
  final Doctor? assignedDoctor;
  final List<Rating> ratings;
  final List<Consultation> consultations;

  @override
  _ProfilePatientContentWidgetState createState() =>
      _ProfilePatientContentWidgetState();
}

class _ProfilePatientContentWidgetState
    extends State<ProfilePatientContentWidget> {
  final PdfProfileService pdfProfileService = PdfProfileService();
  final RatingService ratingService = RatingService();
  final UserService userService = UserService();

  List<bool> _isExpandedList = [];
  bool _isAssignedDoctorTile = false;
  late bool isDoctorAssigned;

  int _selectedRating = 0;

  void _showAddRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Add a Rating",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.yellow,
                        ),
                        iconSize: 25,
                        onPressed: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: CustomTheme.mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _selectedRating == 0
                            ? null
                            : () {
                                for (int index = 0;
                                    index < widget.ratings.length;
                                    index++) {
                                  if (widget.ratings[index].ratingSenderId ==
                                      widget.patient.uid) {
                                    ratingService.deleteRating(
                                        widget.ratings[index].ratingId);
                                  }
                                }

                                ratingService.addRating(
                                  Rating(
                                    ratingReceiverId: widget.patient.doctorId,
                                    ratingId: '',
                                    ratingSenderId: widget.patient.uid,
                                    starsNumber: _selectedRating,
                                  ),
                                );

                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileScreen()),
                                );
                              },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: CustomTheme.mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    isDoctorAssigned = widget.assignedDoctor != null;

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
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: CustomTheme.mainColor),
            ),
            const SizedBox(height: 10),
            Text(
              widget.patient.name,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              widget.patient.email,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 5),
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
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 0),
                  ),
                ],
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        patient: widget.patient,
                        doctor: Doctor(
                            role: '',
                            uid: '',
                            phoneNumber: '',
                            dateOfBirth: '',
                            email: '',
                            gender: '',
                            createdAt: '',
                            password: '',
                            name: ''),
                      ),
                    ),
                  );
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
                  "Edit profile",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color to white
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Assigned Doctor / Therapist',
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
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: isDoctorAssigned
                  ? Container(
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
                              _isAssignedDoctorTile = expanded;
                            });
                          },
                          title: Text(
                            widget.assignedDoctor!.name,
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
                                    children: [
                                      const Text(
                                        'Specialization:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        widget.assignedDoctor!.specialization,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      const Text(
                                        'Email:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        widget.assignedDoctor!.email,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      const Text(
                                        'Phone Number:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        widget.assignedDoctor!.phoneNumber,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      const Text(
                                        'Rating:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ...List.generate(5, (index) {
                                            double averageRating = widget
                                                    .ratings.isNotEmpty
                                                ? widget.ratings
                                                        .map((rating) =>
                                                            rating.starsNumber)
                                                        .reduce(
                                                            (a, b) => a + b) /
                                                    widget.ratings.length
                                                : 0.0;

                                            if (index < averageRating.floor()) {
                                              return Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                              );
                                            } else if (index < averageRating &&
                                                (averageRating - index) >=
                                                    0.5) {
                                              return Icon(
                                                Icons.star_half,
                                                color: Colors.yellow,
                                              );
                                            } else {
                                              return Icon(
                                                Icons.star_border,
                                                color: Colors.yellow,
                                              );
                                            }
                                          }),
                                          Text(
                                            '(${widget.ratings.length})',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
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
                                                    await userService
                                                        .updateUserField(
                                                            widget.patient.uid,
                                                            'doctorId',
                                                            '');
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfileScreen()),
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    elevation:
                                                        0, // Remove elevation
                                                  ),
                                                  child: const Text(
                                                    "Unassign",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors
                                                          .white, // Set text color to white
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
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
                                                    _showAddRatingDialog();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    elevation:
                                                        0, // Remove elevation
                                                  ),
                                                  child: const Text(
                                                    "Add a rating",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors
                                                          .white, // Set text color to white
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
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
                              _isAssignedDoctorTile = expanded;
                            });
                          },
                          title: Text(
                            'No doctor assigned yet',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      blurRadius: 20, // Blur radius
                      offset: Offset(0, 0), // Offset of the shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(30),
                ),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ShowAllDoctorsOrTherapistsScreen()),
                    ).then((result) {
                      print("Returned result: $result"); // Debugging output
                      if (result == true) {
                        setState(() {});
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: widget.assignedDoctor?.name != ''
                      ? const Text(
                          'Change Doctor / Therapist',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Choose Doctor / Therapist',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Upcoming Consultations',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: widget.consultations.length != 0
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.consultations.length,
                      itemBuilder: (context, index) {
                        final medicalHistory = widget.consultations[index];
                        return Container(
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
                                  _isExpandedList[index] = expanded;
                                });
                              },
                              title: Text(
                                medicalHistory.title,
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Date:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          medicalHistory.date,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
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
                                          medicalHistory.treatmentPlan,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
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
                                          medicalHistory.notes,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                        SizedBox(height: 10),
                                        CustomSlideAction(),
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
                        'No consultations scheduled.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Medical History',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: widget.consultations.length != 0
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.consultations.length,
                      itemBuilder: (context, index) {
                        final medicalHistory = widget.consultations[index];
                        return Container(
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
                                  _isExpandedList[index] = expanded;
                                });
                              },
                              title: Text(
                                medicalHistory.title,
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Date:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          medicalHistory.date,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
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
                                          medicalHistory.treatmentPlan,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
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
                                          medicalHistory.notes,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                        SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            width: double.infinity,
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
                                                        medicalHistory);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                elevation:
                                                    0, // Remove elevation
                                              ),
                                              child: const Text(
                                                "Download Consultation",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors
                                                      .white, // Set text color to white
                                                ),
                                              ),
                                            ),
                                          ),
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
