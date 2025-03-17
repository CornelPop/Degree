import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Exercise.dart';

class ExerciseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Get all exercises
  Future<List<Exercise>> getAllExercises() async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection('exercises').get();

      return querySnapshot.docs
          .map((doc) => Exercise.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting exercises: $e");
      return [];
    }
  }

  // Get exercise by ID
  Future<Exercise?> getExerciseById(String exerciseId) async {
    try {
      DocumentSnapshot docSnapshot = await firestore.collection('exercises').doc(exerciseId).get();

      if (docSnapshot.exists) {
        return Exercise.fromMap(docSnapshot.data() as Map<String, dynamic>);
      } else {
        print("Exercise not found.");
        return null;
      }
    } catch (e) {
      print("Error getting exercise: $e");
      return null;
    }
  }

  // Add a new exercise
  Future<void> addExercise(Exercise exercise) async {
    try {
      DocumentReference docRef = await firestore.collection('exercises').add(exercise.toMap());
      await updateExerciseField(docRef.id, 'exerciseId', docRef.id);
    } catch (e) {
      print("Error adding exercise: $e");
    }
  }

  Future<void> addFavoriteExercise(String userId, String exerciseId) async {
    try {

      Exercise? exercise = await getExerciseById(exerciseId);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favoriteExercises')
          .doc(exerciseId)
          .set(exercise!.toMap());
    } catch (e) {
      print("Error adding favorite exercise: $e");
    }
  }

  Future<void> removeFavoriteExercise(String userId, String exerciseId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favoriteExercises')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      print("Error removing favorite exercise: $e");
    }
  }

  Future<bool> isFavoriteExercise(String userId, String exerciseId) async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favoriteExercises')
          .doc(exerciseId)
          .get();

      return doc.exists;
    } catch (e) {
      print("Error checking favorite exercise: $e");
      return false;
    }
  }

  Future<List<String>> getFavoriteExercises(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favoriteExercises')
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("Error getting favorite exercises: $e");
      return [];
    }
  }

  // Update an existing exercise
  Future<void> updateExercise(String exerciseId, Exercise exerciseDetails) async {
    try {
      await firestore.collection('exercises').doc(exerciseId).update(exerciseDetails.toMap());
    } catch (e) {
      print("Error updating exercise: $e");
    }
  }

  // Delete an exercise
  Future<void> deleteExercise(String exerciseId) async {
    try {
      await firestore.collection('exercises').doc(exerciseId).delete();
      print("Exercise with ID: $exerciseId deleted successfully.");
    } catch (e) {
      print("Error deleting exercise: $e");
    }
  }

  // Update a specific field of an exercise
  Future<void> updateExerciseField(String exerciseId, String field, String value) async {
    try {
      await firestore.collection('exercises').doc(exerciseId).update({field: value});
      print("Updated exerciseId field successfully.");
    } catch (e) {
      print("Error updating exercise field: $e");
    }
  }
}
