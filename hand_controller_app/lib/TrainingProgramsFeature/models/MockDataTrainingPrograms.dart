import 'Exercise.dart';

List<Exercise> getExercises() {
  const int lowThumb = 2040;
  const int highThumb = 2500;

  const int lowIndex = 1870;
  const int highIndex = 2850;

  const int lowMiddle = 1970;
  const int highMiddle = 2800;

  const int lowRing = 2060;
  const int highRing = 2800;

  const int lowPinky = 1905;
  const int highPinky = 2900;

  Exercise exercise1 = Exercise(
    exerciseId: '',
    name: 'Fist to index up',
    description: '',
    numberOfTimes: 10,
    targetValues: {
      'Thumb': highThumb,
      'Index': lowIndex,
      'Middle': highMiddle,
      'Ring': highRing,
      'Pinky': highPinky
    },
    baseValues: {
      'Thumb': highThumb,
      'Index': highIndex,
      'Middle': highMiddle,
      'Ring': highRing,
      'Pinky': highPinky
    },
    animationPath: 'assets/animations/fist_to_index_up.json',
  );

  Exercise exercise2 = Exercise(
    exerciseId: '',
    name: 'Fist to open palm',
    description: '',
    numberOfTimes: 10,
    targetValues: {
      'Thumb': lowThumb,
      'Index': lowIndex,
      'Middle': lowMiddle,
      'Ring': lowRing,
      'Pinky': lowPinky
    },
    baseValues: {
      'Thumb': highThumb,
      'Index': highIndex,
      'Middle': highMiddle,
      'Ring': highRing,
      'Pinky': highPinky
    },
    animationPath: 'assets/animations/fist_open.json',
  );

  Exercise exercise3 = Exercise(
    exerciseId: '',
    name: 'Fist to index and middle up',
    description: '',
    numberOfTimes: 10,
    targetValues: {
      'Thumb': highThumb,
      'Index': lowIndex,
      'Middle': lowMiddle,
      'Ring': highRing,
      'Pinky': highPinky
    },
    baseValues: {
      'Thumb': highThumb,
      'Index': highIndex,
      'Middle': highMiddle,
      'Ring': highRing,
      'Pinky': highPinky
    },
    animationPath: 'assets/animations/fist_to_index_and_middle_up.json',
  );

  Exercise exercise4 = Exercise(
    exerciseId: '',
    name: 'Open hand to index up',
    description: '',
    numberOfTimes: 10,
    targetValues: {
      'Thumb': highThumb,
      'Index': lowIndex,
      'Middle': highMiddle,
      'Ring': highRing,
      'Pinky': highPinky
    },
    baseValues: {
      'Thumb': lowThumb,
      'Index': lowIndex,
      'Middle': lowMiddle,
      'Ring': lowRing,
      'Pinky': lowPinky
    },
    animationPath: 'assets/animations/open_hand_to_index_up.json',
  );

  Exercise exercise5 = Exercise(
    exerciseId: '',
    name: 'Open hand to index, middle and ring up',
    description: '',
    numberOfTimes: 10,
    targetValues: {
      'Thumb': highThumb,
      'Index': lowIndex,
      'Middle': lowMiddle,
      'Ring': lowRing,
      'Pinky': highPinky
    },
    baseValues: {
      'Thumb': lowThumb,
      'Index': lowIndex,
      'Middle': lowMiddle,
      'Ring': lowRing,
      'Pinky': lowPinky
    },
    animationPath: 'assets/animations/open_hand_to_index_middle_ring_up.json',
  );

  Exercise exercise6 = Exercise(
    exerciseId: '',
    name: 'Fist to thumb up',
    description: '',
    numberOfTimes: 10,
    targetValues: {
      'Thumb': lowThumb,
      'Index': lowIndex,
      'Middle': lowMiddle,
      'Ring': lowRing,
      'Pinky': highPinky
    },
    baseValues: {
      'Thumb': lowThumb,
      'Index': lowIndex,
      'Middle': lowMiddle,
      'Ring': lowRing,
      'Pinky': lowThumb
    },
    animationPath: 'assets/animations/fist_to_thumb_up.json',
  );

  Exercise exercise7 = Exercise(
    exerciseId: '',
    name: 'Fist to index, middle and ring up',
    description: '',
    numberOfTimes: 10,
    targetValues: {
      'Thumb': highThumb,
      'Index': lowIndex,
      'Middle': lowMiddle,
      'Ring': lowRing,
      'Pinky': highPinky
    },
    baseValues: {
      'Thumb': highThumb,
      'Index': highIndex,
      'Middle': highMiddle,
      'Ring': highRing,
      'Pinky': highPinky
    },
    animationPath: 'assets/animations/fist_to_index_middle_ring_up.json',
  );

  Exercise exercise8 = Exercise(
    exerciseId: '',
    name: 'Palm to index down',
    description: '',
    numberOfTimes: 10,
    targetValues: {
      'Thumb': lowThumb,
      'Index': highIndex,
      'Middle': lowMiddle,
      'Ring': lowRing,
      'Pinky': lowPinky
    },
    baseValues: {
      'Thumb': lowThumb,
      'Index': lowIndex,
      'Middle': lowMiddle,
      'Ring': lowRing,
      'Pinky': lowPinky
    },
    animationPath: 'assets/animations/first.json',
  );

  return [
    exercise1,
    exercise2,
    exercise3,
    exercise4,
    exercise5,
    exercise6,
    exercise7,
    exercise8,
  ];
}
