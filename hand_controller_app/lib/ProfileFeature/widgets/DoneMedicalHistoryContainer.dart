import 'package:flutter/material.dart';
import 'package:hand_controller_app/GlobalThemeData.dart';
import 'package:hand_controller_app/ProfileFeature/models/MedicalHistory.dart';


class DoneMedicalHistoryContainer extends StatelessWidget {
  final Consultation medicalHistory;

  DoneMedicalHistoryContainer({
    required this.medicalHistory
  });

  @override
  Widget build(BuildContext context) {
    Color? iconColor;
    List<double> opacities;
    Color bgColor;

    return Container(
        height: MediaQuery.of(context).size.height * 0.15,
        decoration: BoxDecoration(
          color: CustomTheme.accentColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(medicalHistory.title, style: TextStyle(color: Colors.white),),
            Text(medicalHistory.date, style: TextStyle(color: Colors.white),),
            Text(medicalHistory.treatmentPlan, style: TextStyle(color: Colors.white),),
            Text(medicalHistory.notes, style: TextStyle(color: Colors.white),),
          ],
        ),
      );
  }
}

