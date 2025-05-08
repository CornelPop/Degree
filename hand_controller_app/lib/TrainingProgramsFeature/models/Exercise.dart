class Exercise {
  final String exerciseId;
  final String name;
  final String description;
  final int numberOfTimes;
  final Map<String, int> targetValues;
  final Map<String, int> baseValues;
  final String animationPath;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.description,
    required this.numberOfTimes,
    required this.targetValues,
    required this.baseValues,
    required this.animationPath
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'description': description,
      'numberOfTimes': numberOfTimes,
      'targetValues': targetValues,
      'baseValues': baseValues,
      'animationPath': animationPath
    };
  }

  static Exercise fromMap(Map<String, dynamic> map) {
    return Exercise(
      exerciseId: map['exerciseId'],
      name: map['name'],
      description: map['description'],
      numberOfTimes: map['numberOfTimes'],
      animationPath: map['animationPath'],
      targetValues: Map<String, int>.from(map['targetValues']),
      baseValues: Map<String, int>.from(map['baseValues']),
    );
  }
}
