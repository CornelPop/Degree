import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/models/TrainingProgram.dart';

class MockTrainingProgramService {
  final FakeFirebaseFirestore firestore;

  MockTrainingProgramService() : firestore = FakeFirebaseFirestore();

  Future<void> addTrainingProgram(TrainingProgram trainingProgram) async {
    try {
      final docRef = await firestore.collection('trainingPrograms').add(trainingProgram.toMap());
      await updateTrainingProgramField(docRef.id, 'trainingProgramId', docRef.id);
    } catch (e) {
      print("Mock: Error adding training program: $e");
    }
  }

  Future<List<TrainingProgram>> getAllTrainingPrograms() async {
    try {
      final snapshot = await firestore.collection('trainingPrograms').get();
      return snapshot.docs
          .map((doc) => TrainingProgram.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Mock: Error getting all training programs: $e");
      return [];
    }
  }

  Future<TrainingProgram?> getTrainingProgramById(String id) async {
    try {
      final doc = await firestore.collection('trainingPrograms').doc(id).get();
      if (doc.exists) {
        return TrainingProgram.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Mock: Error getting training program by ID: $e");
      return null;
    }
  }

  Future<List<TrainingProgram>> getAllTrainingProgramsCreatedByDoctorId(String doctorId) async {
    try {
      final snapshot = await firestore
          .collection('trainingPrograms')
          .where('createdById', isEqualTo: doctorId)
          .get();
      return snapshot.docs
          .map((doc) => TrainingProgram.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Mock: Error getting programs by doctor ID: $e");
      return [];
    }
  }

  Future<void> updateTrainingProgramField(String id, String field, dynamic value) async {
    try {
      await firestore.collection('trainingPrograms').doc(id).update({field: value});
    } catch (e) {
      print("Mock: Error updating field: $e");
    }
  }

  Future<void> deleteTrainingProgram(String id) async {
    try {
      await firestore.collection('trainingPrograms').doc(id).delete();
    } catch (e) {
      print("Mock: Error deleting program: $e");
    }
  }

  Future<int> countProgramsByDoctorAndCategory({
    required String doctorId,
    required String category,
  }) async {
    try {
      final snapshot = await firestore
          .collection('trainingPrograms')
          .where('createdById', isEqualTo: doctorId)
          .where('category', isEqualTo: category)
          .get();
      return snapshot.size;
    } catch (e) {
      print("Mock: Error counting programs: $e");
      return 0;
    }
  }
}
