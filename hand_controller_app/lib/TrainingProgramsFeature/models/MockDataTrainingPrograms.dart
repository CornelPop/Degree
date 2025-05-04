import 'Exercise.dart';
import 'TrainingProgram.dart';

List<TrainingProgram> getTrainingPrograms() {

  Exercise exercise1 = Exercise(
    exerciseId: '',
    name: 'Fingers Flex',
    description: '',
    numberOfTimes: 10,
    targetValues: {'Thumb': 2700, 'Index': 2700, 'Middle': 2700, 'Ring': 2700, 'Pinky': 2700},
    animationPath: ''
  );

  Exercise exercise2 = Exercise(
    exerciseId: '',
    name: 'Fingers Relax',
    description: '',
    numberOfTimes: 10,
    targetValues: {'Thumb': 2700, 'Index': 2700, 'Middle': 2700, 'Ring': 2700, 'Pinky': 2700},
    animationPath: ''
  );

  Exercise exercise3 = Exercise(
    exerciseId: '',
    name: 'Index middle up',
    description: '',
    numberOfTimes: 10,
    targetValues: {'Thumb': 2700, 'Index': 2700, 'Middle': 2700, 'Ring': 2700, 'Pinky': 2700},
    animationPath: ''
  );

  DateTime now = DateTime.now();

  TrainingProgram program1 = TrainingProgram(
    createdById: '',
    trainingProgramId: '',
    name: 'Beginner Program',
    duration: 10,
    exercises: [exercise1, ],
    category: 'Beginner',
    date: now,
    createdAt: now
  );

  TrainingProgram program2 = TrainingProgram(
    trainingProgramId: '',
    name: 'Beginner Program',
    category: 'Beginner',
    duration: 10,
    date: now,
    createdAt: now,
    createdById: '',
    exercises: [exercise1, exercise1, exercise1, exercise1],
  );

  TrainingProgram program3 = TrainingProgram(
    trainingProgramId: '',
    name: 'Intermediate Program',
    category: 'Intermediate',
    duration: 15,
    createdAt: now,
    createdById: '',
    date: now,
    exercises: [exercise1, exercise2, exercise1, exercise2],
  );

  TrainingProgram program4 = TrainingProgram(
    trainingProgramId: '',
    name: 'Intermediate Program',
    category: 'Intermediate',
    duration: 15,
    createdAt: now,
    createdById: '',
    date: now,
    exercises: [exercise1, exercise2, exercise1, exercise2],
  );

  TrainingProgram program5 = TrainingProgram(
    trainingProgramId: '',
    name: 'Difficult Program',
    category: 'Difficult',
    duration: 20,
    createdAt: now,
    createdById: '',
    date: now,
    exercises: [exercise1, exercise2, exercise1, exercise2, exercise1, exercise2],
  );

  TrainingProgram program6 = TrainingProgram(
    trainingProgramId: '',
    name: 'Difficult Program',
    category: 'Difficult',
    duration: 20,
    createdAt: now,
    createdById: '',
    date: now,
    exercises: [exercise1, exercise2, exercise1, exercise2, exercise1, exercise2],
  );

  return [program1, program2, program3, program4, program5, program6];
}
