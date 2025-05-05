import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/models/Exercise.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/TrainingProgramScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/services/ExerciseService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/services/TrainingProgramService.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import '../../AlertDialogs/ErrorDialogWidget.dart';
import '../../AuthFeature/models/User.dart';
import '../../GlobalThemeData.dart';
import '../../TrainingProgramsFeature/models/TrainingProgram.dart';
import '../models/MockDataTrainingPrograms.dart';

class ReviewTrainingProgramScreen extends StatefulWidget {
  final List<Exercise> trainingProgramExercises;
  final String userId;
  final bool isEdit;
  final TrainingProgram? trainingProgram;

  const ReviewTrainingProgramScreen(
      {Key? key,
      required this.trainingProgramExercises,
      required this.userId,
      this.trainingProgram,
      required this.isEdit,})
      : super(key: key);

  @override
  ReviewTrainingProgramScreenState createState() =>
      ReviewTrainingProgramScreenState();
}

class ReviewTrainingProgramScreenState
    extends State<ReviewTrainingProgramScreen> {
  final TrainingProgramService trainingProgramService =
      TrainingProgramService();
  final ExerciseService exerciseService = ExerciseService();

  User? user;

  String category = '';
  List<Exercise> exercises = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    exercises = widget.trainingProgramExercises;
    widget.isEdit == true ? category = widget.trainingProgram!.category : null;
    widget.isEdit == true ? nameController.text = widget.trainingProgram!.name : null;
    widget.isEdit == true
        ? durationController.text = widget.trainingProgram!.duration.toString()
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    String errors = '';

                    if (nameController.text.isEmpty) {
                      errors += 'Please enter the name.\n';
                    }

                    if (durationController.text.isEmpty) {
                      errors += 'Please enter the duration.\n';
                    }

                    if (category == '') {
                      errors += 'Please select a category.\n';
                    }

                    if (errors.isNotEmpty) {
                      ErrorDialogWidget(message: errors.trim())
                          .showErrorDialog(context);
                      return;
                    } else {
                      widget.isEdit == false
                          ? await trainingProgramService.addTrainingProgram(
                              TrainingProgram(
                                  trainingProgramId: '',
                                  name: nameController.text,
                                  duration: int.parse(durationController.text),
                                  category: category,
                                  exercises: exercises,
                                  date: DateTime.now(),
                                  createdAt: DateTime.now(),
                                  createdById: widget.userId))
                          : await trainingProgramService.updateTrainingProgram(
                              TrainingProgram(
                                  trainingProgramId: widget.trainingProgram!.trainingProgramId,
                                  name: nameController.text,
                                  duration: int.parse(durationController.text),
                                  category: category,
                                  exercises: exercises,
                                  date: DateTime.now(),
                                  createdAt: DateTime.now(),
                                  createdById: widget.userId));

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                const TrainingProgramScreen()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                  child: widget.isEdit == false
                      ? const Text(
                          'Create Program',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Program',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        body: reviewTrainingProgramWidget());
  }

  Widget reviewTrainingProgramWidget() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              height: kToolbarHeight + 20,
            ),
            Column(
              children: [
                AppBarWidget(
                  leadingIcon: Icons.arrow_back,
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Exercises added:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ReorderableListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          color: Colors.white.withOpacity(0.1),
                          key: Key('$index'),
                          child: Slidable(
                            //key: Key('$index'),
                            startActionPane: ActionPane(
                              extentRatio: 0.35,
                              motion: StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: ((context) {
                                    if (exercises.length > 5) {
                                      setState(() {
                                        exercises.removeAt(index);
                                      });
                                    } else {
                                      ErrorDialogWidget(
                                              message:
                                                  'You need to add at least 5 exercises. You can remove anymore.')
                                          .showErrorDialog(context);
                                    }
                                  }),
                                  icon: Icons.delete,
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  label: 'Remove',
                                ),
                              ],
                            ),
                            child: ListTile(
                              tileColor: Colors.transparent,
                              selectedTileColor: CustomTheme.accentColor2,
                              selected: true,
                              title: Text(
                                exercises[index].name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "Repetitions: ${exercises[index].numberOfTimes}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: ReorderableDragStartListener(
                                index: index,
                                child: const Icon(
                                  Icons.drag_handle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      onReorder: (oldIndex, newIndex) =>
                          updateItems(oldIndex, newIndex),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Fill out this form",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
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
                          color: Colors.black.withOpacity(0.2),
                          // Shadow color
                          blurRadius: 20,
                          // Blur radius
                          offset: Offset(0, 0), // Offset of the shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name of the program',
                        prefixIcon:
                            Icon(Icons.fitness_center, color: Colors.white),
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
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
                          color: Colors.black.withOpacity(0.2),
                          // Shadow color
                          blurRadius: 20,
                          // Blur radius
                          offset: Offset(0, 0), // Offset of the shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration of the program',
                        prefixIcon:
                            Icon(Icons.access_time, color: Colors.white),
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Choose the category from the options below:",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
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
                          color: Colors.black.withOpacity(0.2),
                          // Shadow color
                          blurRadius: 20,
                          // Blur radius
                          offset: Offset(0, 0), // Offset of the shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      category = 'Beginner';
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: category == 'Beginner'
                                          ? CustomTheme.accentColor2
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: category == 'Beginner'
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Text(
                                      'Beginner',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      category = 'Intermediate';
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: category == 'Intermediate'
                                          ? CustomTheme.accentColor4
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: category == 'Intermediate'
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Text(
                                      'Intermediate',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      category = 'Difficult';
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: category == 'Difficult'
                                          ? CustomTheme.accentColor3
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: category == 'Difficult'
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Text(
                                      'Difficult',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void updateItems(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex--;
      }
      final Exercise exercise = exercises.removeAt(oldIndex);
      exercises.insert(newIndex, exercise);
    });
  }
}
