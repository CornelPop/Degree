import 'package:flutter/material.dart';
import 'package:hand_controller_app/ProgressTrackingFeature/widgets/DoneProgramContainerWidget.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import '../../AuthFeature/models/User.dart';
import '../../AuthFeature/services/AuthService.dart';
import '../../AuthFeature/services/UserService.dart';
import '../../AlertDialogs/ExitDialogWidget.dart';
import '../../GlobalThemeData.dart';
import '../../TrainingProgramsFeature/models/TrainingProgram.dart';

class AllCompletedTrainingProgramsScreen extends StatefulWidget {
  final List<TrainingProgram> completedPrograms;
  final List<TrainingProgram> favoritePrograms;
  final User user;

  const AllCompletedTrainingProgramsScreen({Key? key, required this.completedPrograms, required this.favoritePrograms, required this.user})
      : super(key: key);

  @override
  _AllCompletedTrainingProgramsScreenState createState() => _AllCompletedTrainingProgramsScreenState();
}

class _AllCompletedTrainingProgramsScreenState extends State<AllCompletedTrainingProgramsScreen> {
  final UserService userService = UserService();
  final AuthService authService = AuthService();

  String name = '';
  String email = '';
  String role = '';

  late Future<void> _fetchUserDataFuture;

  String _sortField = 'date';
  bool _isAscending = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDataFuture = fetchUserData();
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
      print('No UID found in SharedPreferences.');
    }
  }

  void _sortPrograms(String field) {
    setState(() {
      if (_sortField == field) {
        _isAscending = !_isAscending;
      } else {
        _sortField = field;
        _isAscending = true;
      }

      widget.completedPrograms.sort((a, b) {
        int comparison;
        switch (_sortField) {
          case 'date':
            comparison = a.date.compareTo(b.date);
            break;
          case 'duration':
            comparison = a.duration.compareTo(b.duration);
            break;
          case 'name':
          default:
            comparison = a.name.compareTo(b.name);
        }
        return _isAscending ? comparison : -comparison;
      });
    });
  }

  Widget _buildSortButton(String field, String label) {
    return GestureDetector(
      onTap: () => _sortPrograms(field),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _sortField == field
              ? CustomTheme.accentColor2
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _sortField == field ? Colors.white : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (_sortField == field)
              Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await ExitDialog.showExitDialog(context);
      },
      child: Scaffold(
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
                const AppBarWidget(leadingIcon: Icons.arrow_back,),
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
                                colors: [
                                  CustomTheme.mainColor2,
                                  CustomTheme.mainColor
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: const Center(
                                child: CircularProgressIndicator()));
                      } else {
                        return showAllProgramsContentWidget();
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

  Widget showAllProgramsContentWidget() {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Training Programs Completed: ${widget.completedPrograms.length}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Sort the Training Programs by:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [CustomTheme.accentColor4, CustomTheme.accentColor2],
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
                child: Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSortButton('name', 'Name'),
                      SizedBox(width: 10),
                      _buildSortButton('date', 'Date'),
                      SizedBox(width: 10),
                      _buildSortButton('duration', 'Duration'),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.completedPrograms.length,
                itemBuilder: (context, index) {
                  final program = widget.completedPrograms[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DoneProgramContainer(
                      // userId: widget.user.uid,
                      // favoriteTrainingPrograms: widget.favoritePrograms,
                      program: program,
                      title: program.name,
                      date:
                          'Done in ${program.date.day} / ${program.date.month} / ${program.date.year}',
                      subtitle:
                          '${program.duration} MINS  ●  ${program.exercises.length} EXERCISES',
                      difficulty: program.category,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
