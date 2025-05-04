import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hand_controller_app/AuthFeature/screens/SignInScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hand_controller_app/NotificationFeature/services/NotificationService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/TrainingProgramScreen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'AuthFeature/services/SharedPrefService.dart';
import 'firebase_options.dart';

Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().initNotifications();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  bool isLoading = true;
  late SharedPrefsService _sharedPrefsService;

  @override
  void initState() {
    super.initState();
    _sharedPrefsService = SharedPrefsService();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool? rememberMe = await _sharedPrefsService.getRememberMe();
    setState(() {
      isLoggedIn = rememberMe ?? false;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HandHero',
      debugShowCheckedModeBanner: false,
      home: isLoading? const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      )
          : isLoggedIn
          ? const TrainingProgramScreen()
          : const SignInScreen(),
    );
  }
}