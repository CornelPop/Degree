import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../AuthFeature/models/User.dart';
import '../../GlobalThemeData.dart';
import '../models/TrainingProgram.dart';
import '../services/TrainingProgramService.dart';
import 'StartTrainingProgramScreen.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final TrainingProgram program;
  final User? user;
  final bool isFavorite;
  final void Function(String programId, bool isNowFavorite) onFavoriteChanged;

  const ProgramDetailsScreen(
      {Key? key, required this.program, required this.isFavorite, required this.user, required this.onFavoriteChanged})
      : super(key: key);

  @override
  ProgramDetailsScreenState createState() => ProgramDetailsScreenState();
}

class ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  late Color bgContainer;
  final TrainingProgramService trainingProgramService = TrainingProgramService();
  late bool isFave;

  @override
  void initState() {
    super.initState();
    isFave = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      isFave = !isFave;
    });

    if (isFave) {
      trainingProgramService.addFavoriteTrainingProgram(
        widget.user!.uid,
        widget.program.trainingProgramId,
      );
      widget.onFavoriteChanged(widget.program.trainingProgramId, true);
    } else {
      trainingProgramService.removeFavoriteTrainingProgram(
        widget.user!.uid,
        widget.program.trainingProgramId,
      );
      widget.onFavoriteChanged(widget.program.trainingProgramId, false);
    }
  }
  @override
  Widget build(BuildContext context) {

    if (widget.program.category == 'Beginner') {
      bgContainer = CustomTheme.accentColor;
    } else if (widget.program.category == 'Intermediate') {
      bgContainer = CustomTheme.accentColor2;
    } else {
      bgContainer = CustomTheme.accentColor3;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CustomTheme.mainColor2,
              CustomTheme.mainColor,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 150.0,
              stretch: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isFave ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                  ),
                  onPressed: _toggleFavorite,
                ),
                IconButton(
                  icon: Icon(
                    Icons.question_mark,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomTheme.mainColor2,
                      CustomTheme.mainColor,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    widget.program.name,
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: CustomTheme.accentColor4,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.program.duration} MINS  ●  ${widget.program.exercises.length} EXERCISES',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    widget.program.exercises.isEmpty
                        ? Center(child: Text('No exercises available'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: widget.program.exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = widget.program.exercises[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: bgContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(35.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.bolt,
                                          color: Colors.blue[900], size: 35),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exercise.name,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'x${exercise.numberOfTimes}',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      // Icon(Icons.bolt,
                                      //     color: Colors.blue[900], size: 35),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Lottie.asset(
                                          "assets/animations/fist_open.json",
                                          width: 75,
                                          height: 75,
                                          fit: BoxFit.fill,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StartTrainingProgramScreen(user: widget.user, program: widget.program),
                    ),
                  );
                },
                child: const Text(
                  'Start Program',
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
    );
  }
}
