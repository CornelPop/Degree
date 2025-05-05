import 'Exercise.dart';

List<Exercise> getExercises() {

  const int highTargetValue = 2700;
  const int lowTargetValue = 1900;

  Exercise exercise1 = Exercise(
    exerciseId: '',
    name: 'Fist to index up',
    description: '',
    numberOfTimes: 10,
    targetValues: {'Thumb': highTargetValue, 'Index': lowTargetValue, 'Middle': highTargetValue, 'Ring': highTargetValue, 'Pinky': highTargetValue},
    animationPath: 'assets/animations/fist_to_index_up.json'
  );

  Exercise exercise2 = Exercise(
    exerciseId: '',
    name: 'Fist to open palm',
    description: '',
    numberOfTimes: 10,
    targetValues: {'Thumb': lowTargetValue, 'Index': lowTargetValue, 'Middle': lowTargetValue, 'Ring': lowTargetValue, 'Pinky': lowTargetValue},
    animationPath: 'assets/animations/fist_open.json'
  );

  Exercise exercise3 = Exercise(
    exerciseId: '',
    name: 'Fist to index and middle up',
    description: '',
    numberOfTimes: 10,
    targetValues: {'Thumb': highTargetValue, 'Index': lowTargetValue, 'Middle': lowTargetValue, 'Ring': highTargetValue, 'Pinky': highTargetValue},
    animationPath: 'assets/animations/fist_to_index_and_middle_up.json'
  );

  Exercise exercise4 = Exercise(
    exerciseId: '',
    name: 'Open hand to index up',
    description: '',
    numberOfTimes: 10,
    targetValues: {'Thumb': highTargetValue, 'Index': lowTargetValue, 'Middle': highTargetValue, 'Ring': highTargetValue, 'Pinky': highTargetValue},
    animationPath: 'assets/animations/open_hand_to_index_up.json'
  );

  Exercise exercise5 = Exercise(
    exerciseId: '',
    name: 'Open hand to index, middle and ring up',
    description: '',
    numberOfTimes: 10,
    targetValues: {'Thumb': highTargetValue, 'Index': lowTargetValue, 'Middle': lowTargetValue, 'Ring': lowTargetValue, 'Pinky': highTargetValue},
    animationPath: 'assets/animations/open_hand_to_index_middle_ring_up.json'
  );

  Exercise exercise6 = Exercise(
    exerciseId: '',
    name: 'Fist to thumb up',
    description: '',
    numberOfTimes: 10,
    targetValues: {'Thumb': lowTargetValue, 'Index': lowTargetValue, 'Middle': lowTargetValue, 'Ring': lowTargetValue, 'Pinky': highTargetValue},
    animationPath: 'assets/animations/fist_to_thumb_up.json'
  );

  Exercise exercise7 = Exercise(
    exerciseId: '',
    name: 'Fist to index, middle and ring up',
    description: '',
    numberOfTimes: 10,
    targetValues: {'Thumb': lowTargetValue, 'Index': lowTargetValue, 'Middle': lowTargetValue, 'Ring': lowTargetValue, 'Pinky': highTargetValue},
    animationPath: 'assets/animations/fist_to_index_middle_ring_up.json'
  );

  return [exercise1, exercise2, exercise3, exercise4, exercise5, exercise6, exercise7];
}
