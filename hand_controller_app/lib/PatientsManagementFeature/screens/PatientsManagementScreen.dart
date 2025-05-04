import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/services/AuthService.dart';
import 'package:hand_controller_app/AuthFeature/services/UserService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/EntireMedicalHistoryScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/EntireProgressTrackingScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/services/TrainingProgramService.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import 'package:hand_controller_app/core/widgets/CustomDrawer.dart';
import '../../AlertDialogs/ExitDialogWidget.dart';
import '../../AuthFeature/models/Doctor.dart';
import '../../AuthFeature/models/Patient.dart';
import '../../AuthFeature/models/User.dart';
import '../../GlobalThemeData.dart';
import '../../core/widgets/LoadingWidget.dart';
import 'package:lottie/lottie.dart';

class PatientsManagementScreen extends StatefulWidget {
  const PatientsManagementScreen({Key? key}) : super(key: key);

  @override
  _PatientsManagementScreenState createState() => _PatientsManagementScreenState();
}

class _PatientsManagementScreenState extends State<PatientsManagementScreen> {
  final UserService userService = UserService();
  final AuthService authService = AuthService();
  final TrainingProgramService trainingProgramService = TrainingProgramService();

  String name = '';
  String email = '';
  String role = '';

  late double screenWidth;
  late double screenHeight;
  late double buttonWidth;
  late double buttonHeight;
  late double containerHeight;

  int numberBeginnerExercises = 0;
  int numberIntermediateExercises = 0;
  int numberDifficultExercises = 0;
  int timeSpentInWorkouts = 0;
  double accuracyOfExercises = 0.0;

  late Future<void> _fetchUserDataFuture;

  bool _isFilterTileExpended = false;

  late List<Patient> patients;
  List<Patient> filteredPatients = [];
  List<bool> _isExpandedList = [];
  TextEditingController searchController = TextEditingController();

  late String userId;

  String _searchByField = 'name';
  String _orderByField = 'name';
  bool _isAscending = true;
  String _searchedString = '';

  Patient? patient;
  Doctor? assignedDoctor;
  Doctor? doctor;

  User? user;

  @override
  void initState() {
    super.initState();
    _fetchUserDataFuture = fetchUserData();
  }

  void _applyFilters() {
    setState(() {
      filteredPatients = patients.where((patient) {
        String valueToSearch = '';
        switch (_searchByField) {
          case 'name':
            valueToSearch = patient.name;
            break;
          case 'email':
            valueToSearch = patient.email;
            break;
        }
        return valueToSearch
            .toLowerCase()
            .contains(_searchedString.toLowerCase());
      }).toList();

      if (_orderByField.isNotEmpty) {
        filteredPatients.sort((a, b) {
          var valueA = '';
          var valueB = '';
          switch (_orderByField) {
            case 'name':
              valueA = a.name.toLowerCase();
              valueB = b.name.toLowerCase();
              break;
            case 'rating':
              valueA = a.email.toString();
              valueB = b.email.toString();
              break;
          }
          return _isAscending
              ? valueA.compareTo(valueB)
              : valueB.compareTo(valueA);
        });
      }
    });
  }

  Widget _buildOrderByButton(String field, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_orderByField == field) {
            _isAscending = !_isAscending;
          } else {
            _orderByField = field;
            _isAscending = true;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _orderByField == field
              ? CustomTheme.accentColor2
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _orderByField == field ? Colors.white : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (_orderByField == field)
              Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchByButton(String field, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchByField = field;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _searchByField == field
              ? CustomTheme.accentColor2
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _searchByField == field ? Colors.white : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _filterBySearchField(String searchText) {
    setState(() {
      filteredPatients = patients.where((patient) {
        String valueToSearch = '';
        switch (_searchByField) {
          case 'name':
            valueToSearch = patient.name;
            break;
          case 'email':
            valueToSearch = patient.email;
            break;
        }
        return valueToSearch.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    });
  }

  Future<void> fetchUserData() async {
    String? uid = await userService.getUserUid();
    if (uid == null) {
      debugPrint('No UID found in SharedPreferences.');
      return;
    }

    Map<String, dynamic>? userData = await userService.getUserData(uid);
    if (userData == null) {
      debugPrint('No user data found.');
      return;
    }

    role = userData['role'] as String;
    name = userData['name'] as String;
    email = userData['email'] as String;

    if (role == 'Patient') {
      patient = Patient.fromMap(userData);
      user = patient;

      numberBeginnerExercises = userData['numberBeginnerExercises'] as int;
      numberIntermediateExercises = userData['numberIntermediateExercises'] as int;
      numberDifficultExercises = userData['numberDifficultExercises'] as int;
      timeSpentInWorkouts = userData['timeSpentInWorkouts'] as int;
      accuracyOfExercises = userData['accuracyOfExercises'] as double;

    } else if (role == 'Doctor') {
      doctor = Doctor.fromMap(userData);
      user = doctor;

      userId = uid;
      List<dynamic> patientsLocal = await userService.getPatientsByDoctorId(uid);
      patients = patientsLocal.cast<Patient>();
      filteredPatients = patients;
      _isExpandedList = List.generate(patients.length, (_) => false);
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    buttonWidth = screenWidth * 0.90;
    buttonHeight = screenHeight * 0.08;
    containerHeight = screenHeight * 0.15;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await ExitDialog.showExitDialog(context);
      },
      child: Scaffold(
        body: FutureBuilder(
          future: _fetchUserDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'An error occurred: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.done && user != null) {
              return Scaffold(
                drawer: CustomDrawer(
                  user: user,
                  selectedTile: 'Patient Management',
                ),
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
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: _buildContent(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('No user data available.'));
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'These are your patients:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                        color: Colors.black.withOpacity(0.2), // Shadow color
                        blurRadius: 20, // Blur radius
                        offset: Offset(0, 0), // Offset of the shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search patients...',
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      border: InputBorder.none,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      _searchedString = value;
                      _filterBySearchField(value);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: CustomTheme.accentColor4,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Theme(
                    data: ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      backgroundColor: Colors.transparent,
                      onExpansionChanged: (bool expanded) {
                        setState(() {
                          _isFilterTileExpended = expanded;
                        });
                      },
                      title: const Text(
                        'Filters',
                        style: TextStyle(color: Colors.white),
                      ),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: CustomTheme.accentColor4,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Search by:',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildSearchByButton('name', 'Name'),
                                          _buildSearchByButton(
                                              'email', 'Email'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Order By:',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildOrderByButton('name', 'Name'),
                                          _buildOrderByButton('email', 'Email'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
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
                                        onPressed: () async {
                                          searchController.clear();
                                          filteredPatients = patients;
                                          _applyFilters();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                          ),
                                          elevation: 0, // Remove elevation
                                        ),
                                        child: const Text(
                                          "Clear All",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // Set text color to white
                                          ),
                                        ),
                                      ),
                                    ),
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
                                          //_applyFilters();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                          ),
                                          elevation: 0, // Remove elevation
                                        ),
                                        child: const Text(
                                          "Apply",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // Set text color to white
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = filteredPatients[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: CustomTheme.accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Theme(
                        data: ThemeData().copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          backgroundColor: Colors.transparent,
                          onExpansionChanged: (bool expanded) {
                            setState(() {
                              _isExpandedList[index] = expanded;
                            });
                          },
                          title: Text(
                            patient.name,
                            style: TextStyle(color: Colors.white),
                          ),
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: CustomTheme.accentColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Name:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      patient.name,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    SizedBox(height: 8),
                                    const Text(
                                      'Gender:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      patient.gender,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    SizedBox(height: 8),
                                    const Text(
                                      'Date of Birth:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      patient.dateOfBirth,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    SizedBox(height: 8),
                                    const Text(
                                      'Phone:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      patient.phoneNumber,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    SizedBox(height: 8),
                                    const Text(
                                      'Email:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      patient.email,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: Container(
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
                                                  color:
                                                  Colors.black.withOpacity(0.2),
                                                  blurRadius: 20,
                                                  offset: Offset(0, 0),
                                                ),
                                              ],
                                              borderRadius:
                                              BorderRadius.circular(30),
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EntireMedicalHistoryScreen(
                                                            patient: patient),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(30),
                                                ),
                                                elevation: 0, // Remove elevation
                                              ),
                                              child: const Text(
                                                "Med. History",
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
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: Container(
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
                                                  color:
                                                  Colors.black.withOpacity(0.2),
                                                  blurRadius: 20,
                                                  offset: Offset(0, 0),
                                                ),
                                              ],
                                              borderRadius:
                                              BorderRadius.circular(30),
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EntireProgressTrackingScreen(
                                                              patient: patient)),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(30),
                                                ),
                                                elevation: 0, // Remove elevation
                                              ),
                                              child: const Text(
                                                "Training",
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
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    showGloveRemovedDialog(context);
                  },
                  child: Text('press'))
            ],
          ),
        ),
      ),
    );
  }
  void showGloveRemovedDialog(BuildContext context) {
    // Create a ValueNotifier to manage glove status dynamically
    ValueNotifier<bool> isGloveOnNotifier = ValueNotifier(
        false); // Default to glove off

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Center(
                child: Text("Ooops, something is wrong"),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animations/glove_removed.json',
                    width: 300,
                    height: 300,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "The glove has been removed. Please put it back to continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Exit button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Exit"),
                      ),
                      // Continue button (disabled if glove is off)
                      ValueListenableBuilder<bool>(
                        valueListenable: isGloveOnNotifier,
                        builder: (context, isGloveOn, child) {
                          return ElevatedButton(
                            onPressed: isGloveOn
                                ? () {
                              Navigator.pop(context);
                            }
                                : null, // Disabled if glove is not on
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isGloveOn
                                  ? Theme
                                  .of(context)
                                  .primaryColor
                                  : Colors.grey,
                            ),
                            child: const Text("Continue"),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
