import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/Exercise.dart';

class ExerciseTileWidget extends StatefulWidget {
  final Exercise exercise;

  const ExerciseTileWidget({Key? key, required this.exercise})
      : super(key: key);

  @override
  _ExerciseTileWidgetState createState() => _ExerciseTileWidgetState();
}

class _ExerciseTileWidgetState extends State<ExerciseTileWidget> {
  int repetitions = 1; // Default repetitions

  void _increaseReps() {
    setState(() {
      repetitions++;
    });
  }

  void _decreaseReps() {
    if (repetitions > 1) {
      setState(() {
        repetitions--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(0),
      ),
      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        title: Text(
          widget.exercise.name,
          style: const TextStyle(color: Colors.white),
        ),
        leading: Icon(Icons.expand_more, color: Colors.white,),
        trailing: IconButton(
          onPressed: () {
            print('Exercise added to program!');
          },
          icon: Icon(
            Icons.add_circle,
            color: Colors.white,
          ),
        ),
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
              ),
              const Text(
                'Repetitions:',
                style: TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: _decreaseReps,
              ),
              Text(
                '$repetitions', // Display repetitions
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: _increaseReps,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
