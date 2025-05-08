import 'package:cloud_firestore/cloud_firestore.dart';
import 'Exercise.dart';

class TrainingProgram {
  final String trainingProgramId;
  final String createdById;
  final String name;
  final String category;
  final int duration;
  DateTime date;
  DateTime createdAt;
  final List<Exercise> exercises;
  final List<List<Map<String, int>>> allValuesTakenForAccuracy;

  TrainingProgram({
    required this.trainingProgramId,
    required this.name,
    required this.duration,
    required this.category,
    required this.exercises,
    required this.date,
    required this.createdById,
    required this.createdAt,
    required this.allValuesTakenForAccuracy,
  });

  void updateDate(DateTime newDate) {
    date = newDate;
  }

  Map<String, dynamic> toMap() {
    return {
      'trainingProgramId': trainingProgramId,
      'createdById': createdById,
      'name': name,
      'category': category,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'duration': duration,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'allValuesTakenForAccuracy': allValuesTakenForAccuracy.map((repList) {
        return {'repetition': repList.map((map) => Map<String, dynamic>.from(map)).toList()};
      }).toList(),
    };
  }


  static TrainingProgram fromMap(Map<String, dynamic> map) {
    return TrainingProgram(
      trainingProgramId: map['trainingProgramId'],
      createdById: map['createdById'],
      name: map['name'],
      category: map['category'],
      date: (map['date'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      duration: map['duration'],
      exercises: List<Exercise>.from(map['exercises'].map((e) => Exercise.fromMap(e))),
      allValuesTakenForAccuracy: map['allValuesTakenForAccuracy'] != null
          ? List<List<Map<String, int>>>.from(
        (map['allValuesTakenForAccuracy'] as List).map(
              (entry) => List<Map<String, int>>.from(
            (entry['repetition'] as List).map(
                  (m) => Map<String, int>.from(m as Map),
            ),
          ),
        ),
      )
          : [],
    );
  }
}
