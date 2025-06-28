import 'package:flutter_test/flutter_test.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/models/TrainingProgram.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/models/Exercise.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/services/mock_training_program_service.dart';

void main() {
  late MockTrainingProgramService service;

  setUp(() {
    service = MockTrainingProgramService();
  });

  test('addTrainingProgram adds program correctly', () async {
    final program = createProgram('');
    await service.addTrainingProgram(program);
    final all = await service.getAllTrainingPrograms();
    expect(all.length, 1);
    expect(all.first.name, equals('Recovery Plan'));
  });

  test('getAllTrainingPrograms returns all added programs', () async {
    await service.addTrainingProgram(createProgram(''));
    await service.addTrainingProgram(createProgram(''));
    final all = await service.getAllTrainingPrograms();
    expect(all.length, 2);
  });

  test('getAllTrainingProgramsCreatedByDoctorId filters by doctor', () async {
    await service.addTrainingProgram(createProgram('', createdBy: 'doc1'));
    await service.addTrainingProgram(createProgram('', createdBy: 'doc2'));
    final result = await service.getAllTrainingProgramsCreatedByDoctorId('doc1');
    expect(result.length, 1);
    expect(result.first.createdById, 'doc1');
  });

  test('getTrainingProgramById returns correct program', () async {
    final program = createProgram('');
    await service.addTrainingProgram(program);
    final all = await service.getAllTrainingPrograms();
    final id = all.first.trainingProgramId;
    final fetched = await service.getTrainingProgramById(id);
    expect(fetched?.name, 'Recovery Plan');
  });

  test('countProgramsByDoctorAndCategory returns correct count', () async {
    await service.addTrainingProgram(createProgram('', createdBy: 'doc1', category: 'Rehab'));
    await service.addTrainingProgram(createProgram('', createdBy: 'doc1', category: 'Rehab'));
    await service.addTrainingProgram(createProgram('', createdBy: 'doc1', category: 'Strength'));
    final count = await service.countProgramsByDoctorAndCategory(doctorId: 'doc1', category: 'Rehab');
    expect(count, 2);
  });

  test('updateTrainingProgramField updates a specific field', () async {
    await service.addTrainingProgram(createProgram(''));
    final all = await service.getAllTrainingPrograms();
    final id = all.first.trainingProgramId;
    await service.updateTrainingProgramField(id, 'name', 'Updated Name');
    final updated = await service.getTrainingProgramById(id);
    expect(updated?.name, 'Updated Name');
  });

  test('deleteTrainingProgram removes program', () async {
    await service.addTrainingProgram(createProgram(''));
    final all = await service.getAllTrainingPrograms();
    final id = all.first.trainingProgramId;
    await service.deleteTrainingProgram(id);
    final after = await service.getAllTrainingPrograms();
    expect(after.isEmpty, true);
  });
}

TrainingProgram createProgram(String id,
    {String createdBy = 'doc123', String category = 'Rehab'}) {
  final now = DateTime.now();
  return TrainingProgram(
    trainingProgramId: id,
    name: 'Recovery Plan',
    duration: 30,
    category: category,
    date: now,
    createdAt: now,
    createdById: createdBy,
    exercises: [
      Exercise(
        exerciseId: 'ex1',
        name: 'Stretch',
        description: 'Stretch slowly.',
        numberOfTimes: 5,
        targetValues: {'index': 90},
        baseValues: {'index': 40},
        animationPath: 'assets/anim/stretch.json',
      ),
    ],
    allValuesTakenForAccuracy: [
      [{'index': 92}]
    ],
  );
}
