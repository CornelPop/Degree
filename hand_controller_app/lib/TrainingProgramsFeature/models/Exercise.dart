class Exercise {
  final String name;
  final String description;
  final int numberOfTimes;
  final Map<String, int> targetValues;

  Exercise({
    required this.name,
    required this.description,
    required this.numberOfTimes,
    required this.targetValues,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'numberOfTimes': numberOfTimes,
      'targetValues': targetValues,
    };
  }

  static Exercise fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'],
      description: map['description'],
      numberOfTimes: map['numberOfTimes'],
      targetValues: Map<String, int>.from(map['targetValues']),
    );
  }
}
