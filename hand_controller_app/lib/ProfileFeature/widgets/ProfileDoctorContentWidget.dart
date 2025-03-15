import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/models/Doctor.dart';
import 'package:hand_controller_app/AuthFeature/models/Patient.dart';

import '../../AuthFeature/services/AuthService.dart';
import '../../AuthFeature/services/UserService.dart';
import '../../GlobalThemeData.dart';
import '../screens/EditProfileScreen.dart';

class ProfileDoctorContentWidget extends StatefulWidget {
  const ProfileDoctorContentWidget({super.key,
    required this.doctor});

  final Doctor doctor;

  @override
  _ProfileDoctorContentWidgetState createState() => _ProfileDoctorContentWidgetState();
}

class _ProfileDoctorContentWidgetState extends State<ProfileDoctorContentWidget> {

  Widget build(BuildContext context)
  {
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
              widget.doctor.name,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              widget.doctor.email,
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
                      builder: (context) => EditProfileScreen(patient: Patient(role: '', password: '', createdAt: '', email: '', uid: '', phoneNumber: '', name: '', gender: '', dateOfBirth: ''), doctor: widget.doctor, ),
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
                    color:
                    Colors.white, // Set text color to white
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Profile Page content goes here',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}