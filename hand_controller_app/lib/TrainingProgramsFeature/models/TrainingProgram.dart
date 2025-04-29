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

  TrainingProgram({
    required this.trainingProgramId,
    required this.name,
    required this.duration,
    required this.category,
    required this.exercises,
    required this.date,
    required this.createdById,
    required this.createdAt,
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
    );
  }
}
