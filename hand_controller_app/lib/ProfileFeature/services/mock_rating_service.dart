import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../models/Rating.dart';

class MockRatingService {
  final FakeFirebaseFirestore firestore;

  MockRatingService() : firestore = FakeFirebaseFirestore();

  Future<void> addRating(Rating rating) async {
    try {
      final existing = await firestore
          .collection('ratings')
          .where('ratingReceiverId', isEqualTo: rating.ratingReceiverId)
          .where('ratingSenderId', isEqualTo: rating.ratingSenderId)
          .get();

      if (existing.docs.isNotEmpty) {
        await firestore.collection('ratings').doc(existing.docs.first.id).delete();
      }

      final docRef = await firestore.collection('ratings').add(rating.toMap());
      await updateRatingField(docRef.id, 'ratingId', docRef.id);
    } catch (e) {
      print('Mock: Error adding rating: \$e');
    }
  }

  Future<List<Rating>> getRatingsByDoctorId(String doctorId) async {
    final snapshot = await firestore
        .collection('ratings')
        .where('ratingReceiverId', isEqualTo: doctorId)
        .get();
    return snapshot.docs
        .map((doc) => Rating.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> deleteRating(String ratingId) async {
    try {
      await firestore.collection('ratings').doc(ratingId).delete();
    } catch (e) {
      print('Mock: Error deleting rating: \$e');
    }
  }

  Future<void> updateRatingField(String ratingId, String field, String value) async {
    try {
      await firestore.collection('ratings').doc(ratingId).update({field: value});
    } catch (e) {
      print('Mock: Error updating rating: \$e');
    }
  }
}
