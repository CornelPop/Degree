import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Rating.dart';

class RatingService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Rating>> getRatingsByDoctorId(String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('ratings')
          .where('ratingReceiverId', isEqualTo: doctorId)
          .get();

      return querySnapshot.docs
          .map((doc) => Rating.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error getting ratings: $e");
      return [];
    }
  }

  Future<void> addRating(Rating rating) async {
    try {
      // Query to check if a rating from this user for the doctor already exists
      QuerySnapshot existingRatingQuery = await firestore
          .collection('ratings')
          .where('ratingReceiverId', isEqualTo: rating.ratingReceiverId)
          .where('ratingSenderId', isEqualTo: rating.ratingSenderId)
          .get();

      if (existingRatingQuery.docs.isNotEmpty) {
        DocumentSnapshot existingRatingDoc = existingRatingQuery.docs.first;
        await firestore.collection('ratings').doc(existingRatingDoc.id).delete();
      }

      DocumentReference docRef = await firestore
          .collection('ratings')
          .add(rating.toMap());

      await updateRatingField(docRef.id, 'ratingId', docRef.id);
    } catch (e) {
      print("Error adding rating: $e");
    }
  }


  Future<void> deleteRating(String ratingId) async {
    try {
      await firestore.collection('ratings').doc(ratingId).delete();
      print("Rating with ID: $ratingId deleted successfully.");
    } catch (e) {
      print("Error deleting rating: $e");
    }
  }

  Future<void> updateRatingField(String ratingId, String field, String value) async {
    try {
      await firestore.collection('ratings').doc(ratingId).update({field: value});
      print("Updated ratingId field successfully.");
    } catch (e) {
      print("Error updating rating: $e");
    }
  }
}
