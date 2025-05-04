import 'package:flutter/material.dart';
import 'package:hand_controller_app/ProfileFeature/models/Consultation.dart';
import 'package:hand_controller_app/ProfileFeature/services/ConsultationService.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../GlobalThemeData.dart';
import '../../NotificationFeature/services/NotificationService.dart';

class CustomSlideAction extends StatefulWidget {

  const CustomSlideAction({super.key,
    required this.consultation});

  final Consultation consultation;

  @override
  _CustomSlideActionState createState() => _CustomSlideActionState();
}

class _CustomSlideActionState extends State<CustomSlideAction> {

  final ConsultationService consultationService = ConsultationService();
  final NotificationService notificationService = NotificationService();

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

          await consultationService.updateConsultationField(
              widget.consultation.consultationId, 'accepted', true);
          final consultationDate = widget.consultation.date.toLocal();
          final now = DateTime.now();

          final int consultationTimeSeconds = consultationDate
              .millisecondsSinceEpoch ~/ 1000;
          final int nowSeconds = now.millisecondsSinceEpoch ~/ 1000;

          final int secondsUntilConsultation = consultationTimeSeconds -
              nowSeconds;

          final int secondsUntil24hNotification = secondsUntilConsultation -
              (24 * 60 * 60);
          final int secondsUntil1hNotification = secondsUntilConsultation -
              (1 * 60 * 60);

          notificationService.scheduleAppointmentNotification(
            id: 1,
            title: 'Reminder: Consultation in 24 hours',
            body: 'You have a consultation scheduled in 24 hours.',
            scheduledNotificationDateTime: DateTime.now().add(Duration(seconds: secondsUntil24hNotification)),
          );

          notificationService.scheduleAppointmentNotification(
            id: 2,
            title: 'Reminder: Consultation in 1 hour',
            body: 'You have a consultation scheduled in 1 hour.',
            scheduledNotificationDateTime: DateTime.now().add(Duration(seconds: secondsUntil1hNotification)),
          );

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
