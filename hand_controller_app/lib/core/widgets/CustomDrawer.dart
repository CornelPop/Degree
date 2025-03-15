import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/services/AuthService.dart';
import 'package:hand_controller_app/ProfileFeature/screens/ProfileScreen.dart';
import 'package:hand_controller_app/ProgressTrackingFeature/screens/ProgressTrackingScreen.dart';
import 'package:hand_controller_app/SettingsFeature/screens/SettingsScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/TrainingProgramScreen.dart';

import '../../AuthFeature/screens/SignInScreen.dart';
import '../../DisplayingValuesFeature/screens/DisplayValuesScreen.dart';
import '../../GlobalThemeData.dart';

class CustomDrawer extends StatelessWidget {
  final String name;
  final String email;
  final String selectedTile; // Indicates which tile should have a different style

  final AuthService _authService = AuthService();

  CustomDrawer({
    Key? key,
    required this.name,
    required this.email,
    required this.selectedTile,
  }) : super(key: key);

  Widget buildListTile(BuildContext context, {required Icon icon, required String text, required VoidCallback onTap}) {
    bool isSelected = text == selectedTile; // Check if this tile is selected

    return Container(
      decoration: isSelected
          ? BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Different background for selected tile
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold text for selected tile
              ),
            ),
          ],
        ),
        onTap: isSelected ? null : onTap, // Disable tap if it's the selected tile
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
                        Text(name, style: const TextStyle(fontSize: 20, color: Colors.white)),
                        SizedBox(height: 10),
                        Text(email, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
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
              text: 'Dashboard Programs',
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
              icon: Icon(Icons.track_changes, color: Colors.white),
              text: 'Progress Tracking',
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
