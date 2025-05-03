import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/services/AuthService.dart';
import 'package:hand_controller_app/PatientsManagementFeature/screens/PatientsManagementScreen.dart';
import 'package:hand_controller_app/ProfileFeature/screens/ProfileScreen.dart';
import 'package:hand_controller_app/ProgressTrackingFeature/screens/ProgressTrackingScreen.dart';
import 'package:hand_controller_app/SettingsFeature/screens/SettingsScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/TrainingProgramScreen.dart';

import '../../AuthFeature/models/User.dart';
import '../../AuthFeature/screens/SignInScreen.dart';
import '../../DisplayingValuesFeature/screens/DisplayValuesScreen.dart';
import '../../GlobalThemeData.dart';

class CustomDrawer extends StatelessWidget {
  final User? user;
  final String selectedTile;

  final AuthService _authService = AuthService();

  CustomDrawer({
    Key? key,
    required this.user,
    required this.selectedTile,
  }) : super(key: key);

  Widget buildListTile(BuildContext context, {required Icon icon, required String text, required VoidCallback onTap}) {
    bool isSelected = text == selectedTile;

    return Container(
      decoration: isSelected
          ? BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      )
          : null,
      child: ListTile(
        title: Row(
          children: [
            icon,
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        onTap: isSelected ? null : onTap,
      ),
    );
  }


  @override
  Drawer build(BuildContext context) {
    return Drawer(
      width: 275,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(5),
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_outline, size: 50, color: Colors.white),
                    SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user!.name, style: const TextStyle(fontSize: 20, color: Colors.white)),
                        SizedBox(height: 10),
                        Text(user!.email, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            buildListTile(
              context,
              icon: Icon(Icons.dashboard, color: Colors.white),
              text: 'Dashboard',
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => TrainingProgramScreen()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
            buildListTile(
              context,
              icon: Icon(Icons.assessment, color: Colors.white),
              text: 'Display Values',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DisplayValuesScreen()));
              },
            ),
            buildListTile(
              context,
              icon: Icon(Icons.assignment, color: Colors.white),
              text: 'Patient Management',
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const PatientsManagementScreen()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
            buildListTile(
              context,
              icon: user!.role == 'Patient' ? Icon(Icons.track_changes, color: Colors.white) : Icon(Icons.view_list, color: Colors.white),
              text: user!.role == 'Patient' ? 'Progress Tracking' : 'Program Management',
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => ProgressTrackingScreen()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
            buildListTile(
              context,
              icon: Icon(Icons.person, color: Colors.white),
              text: 'Profile',
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
            buildListTile(
              context,
              icon: Icon(Icons.settings, color: Colors.white),
              text: 'Settings',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            buildListTile(
              context,
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              text: 'Sign out',
              onTap: () async {
                await _authService.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
