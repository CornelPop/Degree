import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/TrainingProgram.dart';

class TrainingProgramService {
  late final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Get all training programs
  Future<List<TrainingProgram>> getAllTrainingPrograms() async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection('trainingPrograms').get();

      return querySnapshot.docs
          .map((doc) => TrainingProgram.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting training programs: $e");
      return [];
    }
  }

  Future<List<TrainingProgram>> getAllTrainingProgramsCreatedByDoctorId(String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('trainingPrograms')
          .where('createdById', isEqualTo: doctorId)
          .get();

      return querySnapshot.docs
          .map((doc) => TrainingProgram.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting training programs: $e");
      return [];
    }
  }

  Future<int> getTotalCompletionsForDoctorPrograms(String doctorId) async {
    try {
      int totalCompletions = 0;

      QuerySnapshot userSnapshot = await firestore.collection('users').get();

      for (var userDoc in userSnapshot.docs) {
        final userId = userDoc.id;

        QuerySnapshot completedSnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('completedPrograms')
            .get();

        for (var completedDoc in completedSnapshot.docs) {
          final data = completedDoc.data() as Map<String, dynamic>;
          final createdById = data['createdById'];

          if (createdById == doctorId) {
            totalCompletions++;
          }
        }
      }

      return totalCompletions;
    } catch (e) {
      print("Error fetching completions: $e");
      return 0;
    }
  }

  Future<TrainingProgram?> getLastTrainingProgramCreatedByDoctor(String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('trainingPrograms')
          .where('createdById', isEqualTo: doctorId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return TrainingProgram.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      print("Error getting last training program created by doctor: $e");
      return null;
    }
  }

  Future<TrainingProgram?> getTrainingProgramById(String trainingProgramId) async {
    try {
      DocumentSnapshot docSnapshot = await firestore.collection('trainingPrograms').doc(trainingProgramId).get();

      if (docSnapshot.exists) {
        return TrainingProgram.fromMap(docSnapshot.data() as Map<String, dynamic>);
      } else {
        print("Training program not found.");
        return null;
      }
    } catch (e) {
      print("Error getting training program: $e");
      return null;
    }
  }

  Future<int> countProgramsByDoctorAndCategory({
    required String doctorId,
    required String category,
  }) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('trainingPrograms')
          .where('createdById', isEqualTo: doctorId)
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.size;
    } catch (e) {
      print('Error counting training programs: $e');
      return 0;
    }
  }


  // Add a new training program
  Future<void> addTrainingProgram(TrainingProgram trainingProgram) async {
    try {
      DocumentReference docRef = await firestore.collection('trainingPrograms').add(trainingProgram.toMap());
      await updateTrainingProgramField(docRef.id, 'trainingProgramId', docRef.id);
    } catch (e) {
      print("Error adding training program: $e");
    }
  }

  Future<void> addFavoriteTrainingProgram(String userId, String trainingProgramId) async {
    try {

      TrainingProgram? trainingProgram = await getTrainingProgramById(trainingProgramId);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favoriteTrainingPrograms')
          .doc(trainingProgramId)
          .set(trainingProgram!.toMap());
    } catch (e) {
      print("Error adding favorite training program: $e");
    }
  }

  Future<void> removeFavoriteTrainingProgram(String userId, String trainingProgramId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favoriteTrainingPrograms')
          .doc(trainingProgramId)
          .delete();
    } catch (e) {
      print("Error removing favorite training program: $e");
    }
  }

  Future<bool> isFavoriteTrainingProgram(String userId, String trainingProgramId) async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favoriteTrainingPrograms')
          .doc(trainingProgramId)
          .get();

      return doc.exists;
    } catch (e) {
      print("Error checking favorite training program: $e");
      return false;
    }
  }

  Future<List<TrainingProgram>> getFavoriteTrainingPrograms(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favoriteTrainingPrograms')
          .get();

      return querySnapshot.docs
          .map((doc) => TrainingProgram.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting favorite training programs: $e");
      return [];
    }
  }

  // Update an existing training program
  Future<void> updateTrainingProgram(TrainingProgram trainingProgramDetails) async {
    try {
      await firestore.collection('trainingPrograms').doc(trainingProgramDetails.trainingProgramId).update(trainingProgramDetails.toMap());
    } catch (e) {
      print("Error updating training program: $e");
    }
  }

  // Delete a training program
  Future<void> deleteTrainingProgram(String trainingProgramId) async {
    try {
      await firestore.collection('trainingPrograms').doc(trainingProgramId).delete();
      print("Training program with ID: $trainingProgramId deleted successfully.");
    } catch (e) {
      print("Error deleting training program: $e");
    }
  }

  Future<void> updateTrainingProgramField(String trainingProgramId, String field, dynamic value) async {
    try {
      await firestore.collection('trainingPrograms').doc(trainingProgramId).update({field: value});
      print("Updated trainingProgramId field successfully.");
    } catch (e) {
      print("Error updating training program field: $e");
    }
  }
  
  Future<void> updateAccuracyValuesForCompletedProgram(String userId, TrainingProgram trainingProgram, dynamic value) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('completedPrograms')
          .doc(trainingProgram.trainingProgramId)
          .update({'allValuesTakenForAccuracy': value});
      print("Updated accuracy values field successfully.");
    } catch (e) {
      print("Error updating training program accuracy values field $e");
    }
  }

  Future<void> addCompletedProgram(
      String userId, TrainingProgram program) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    program.updateDate(DateTime.now());
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('completedPrograms')
          .add(program.toMap());
    } catch (e) {
      print("Error adding completed program: $e");
    }
  }

  Future<List<TrainingProgram>> getCompletedPrograms(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('completedPrograms')
          .get();

      return querySnapshot.docs
          .map((doc) =>
          TrainingProgram.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting completed programs: $e");
      return [];
    }
  }
}
