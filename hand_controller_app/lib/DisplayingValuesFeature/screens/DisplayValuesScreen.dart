import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/services/AuthService.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import 'package:hand_controller_app/core/widgets/CustomDrawer.dart';
import 'package:http/http.dart' as http;
import '../../AlertDialogs/ExitDialogWidget.dart';
import '../../AuthFeature/services/UserService.dart';
import '../../GlobalThemeData.dart';

class DisplayValuesScreen extends StatefulWidget {
  const DisplayValuesScreen({super.key});

  @override
  _DisplayValuesScreenState createState() => _DisplayValuesScreenState();
}

class _DisplayValuesScreenState extends State<DisplayValuesScreen> {
  final UserService userService = UserService();
  final AuthService authService = AuthService();

  final String esp32IpAddress = "http://192.168.69.136";
  Map<String, int> currentFlexValues = {
    'Thumb': 0,
    'Index': 0,
    'Middle': 0,
    'Ring': 0,
    'Pinky': 0,
  };
  Timer? timer;
  bool isTimerRunning = false;
  String flexSensorValue = '';
  bool isRequestInProgress = false;

  String name = '';
  String email = '';
  String role = '';

  late Future<void> _fetchUserDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchUserDataFuture = fetchUserData();
    startTimer();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    String? uid = await userService.getUserUid();
    if (uid != null) {
      Map<String, dynamic>? userData = await userService.getUserData(uid);
      if (userData != null) {
        setState(() {
          name = userData['name'] as String;
          email = userData['email'] as String;
          role = userData['role'] as String;
        });
      } else {
        print('No user data found.');
      }
    } else {
      print('No UID found.');
    }
  }

  void startTimer() {
    if (!isTimerRunning) {
      isTimerRunning = true;
      timer = Timer.periodic(const Duration(milliseconds: 250), (Timer t) {
        readFlexSensor();
      });
    }
  }

  void stopTimer() {
    if (isTimerRunning) {
      timer?.cancel();
      isTimerRunning = false;
    }
  }

  // void readFlexSensor() async {
  //   // Simulated sensor values; replace this with actual HTTP request
  //   setState(() {
  //     currentFlexValues = {
  //       'Thumb': (currentFlexValues['Thumb']! + 10) % 100,
  //       'Index': (currentFlexValues['Index']! + 15) % 100,
  //       'Middle': (currentFlexValues['Middle']! + 20) % 100,
  //       'Ring': (currentFlexValues['Ring']! + 25) % 100,
  //       'Pinky': (currentFlexValues['Pinky']! + 30) % 100,
  //     };
  //   });
  // }

  Future<void> readFlexSensor() async {
    if (isRequestInProgress) return;  // Prevent new requests if one is still in progress
    isRequestInProgress = true;

    try {
      final response = await http.get(Uri.parse("$esp32IpAddress/READ_FLEX_SENSOR_VALUES"));

      if (response.statusCode == 200) {
        int flexValue = int.parse(response.body.trim());

        setState(() {
          currentFlexValues['Index'] = flexValue;
        });

        print("Flex Sensor Value: $flexValue");
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Request failed: $e");
    } finally {
      isRequestInProgress = false;  // Allow the next request
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await ExitDialog.showExitDialog(context);
      },
      child: Scaffold(
        drawer: CustomDrawer(name: name, email: email, selectedTile: 'Display Values'),
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
                AppBarWidget(),
                Expanded(
                  child: FutureBuilder(
                    future: _fetchUserDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                            child: const Center(
                                child: CircularProgressIndicator()));
                      } else {
                        return displayValuesContentWidget();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget displayValuesContentWidget() {
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildProgressBar('Thumb', currentFlexValues['Thumb']!),
              buildProgressBar('Index', currentFlexValues['Index']!),
              buildProgressBar('Middle', currentFlexValues['Middle']!),
              buildProgressBar('Ring', currentFlexValues['Ring']!),
              buildProgressBar('Pinky', currentFlexValues['Pinky']!),
              if (flexSensorValue.isNotEmpty)
                Text('Flex Sensor Value: $flexSensorValue',
                    style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProgressBar(String label, int value) {
    const int minValue = 200;
    const int maxValue = 850;

    double normalizedValue = (value - minValue) / (maxValue - minValue);
    normalizedValue = normalizedValue.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value', style: const TextStyle(color: Colors.white)),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: normalizedValue),
            duration: const Duration(milliseconds: 250),
            builder: (context, double progress, _) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black.withOpacity(0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 30,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
