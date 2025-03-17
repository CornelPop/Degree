import 'package:flutter/material.dart';
import 'package:hand_controller_app/ProfileFeature/models/Consultation.dart';
import 'package:hand_controller_app/ProfileFeature/services/ConsultationService.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../GlobalThemeData.dart';

class CustomSlideAction extends StatefulWidget {

  const CustomSlideAction({super.key,
    required this.consultation});

  final Consultation consultation;

  @override
  _CustomSlideActionState createState() => _CustomSlideActionState();
}

class _CustomSlideActionState extends State<CustomSlideAction> {

  final ConsultationService consultationService = ConsultationService();

  String text = 'Slide to confirm.';
  bool enabled = true;
  Color iconColor = Colors.white;
  Color outerColor = Colors.transparent;
  Color innerColor = Colors.white.withOpacity(0.3);
  IconData sliderButtonIcon = Icons.double_arrow;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: Colors.black.withOpacity(0.2), // Shadow color
            blurRadius: 20, // Blur radius
            offset: const Offset(0, 0), // Offset of the shadow
          ),
        ],
        borderRadius: BorderRadius.circular(30),
      ),
      child: SlideAction(
        onSubmit: () async {
          setState(() {
            text = 'Consultation confirmed';
            iconColor = Colors.transparent;
            outerColor =
                Colors.transparent;
            innerColor = Colors
                .transparent;
            sliderButtonIcon = Icons.check_circle;
            enabled = false;
          });

          await consultationService.updateConsultationField(widget.consultation.consultationId, 'accepted', true);

        },
        enabled: enabled,
        elevation: 0,
        borderRadius: 30,
        height: 50,
        sliderButtonIconSize: 18,
        sliderButtonIconPadding: 10,
        sliderButtonYOffset: 0,
        innerColor: innerColor,
        outerColor: outerColor,
        sliderButtonIcon: Icon(
          sliderButtonIcon,
          size: 28, //
          color: iconColor,
        ),
        sliderRotate: false,
        submittedIcon: const Icon(
          Icons.check,
          color: Colors.white,
        ),

        text: text,
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
