import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Consultation.dart';

class MockConsultationService {
  final FakeFirebaseFirestore firestore;

  MockConsultationService() : firestore = FakeFirebaseFirestore();

  Future<void> addConsultation(Consultation consultation) async {
    try {
      final docRef = await firestore.collection('consultations').add(consultation.toMap());
      await updateConsultationField(docRef.id, 'consultationId', docRef.id);
    } catch (e) {
      print("Mock: Error adding consultation: $e");
    }
  }

  Future<List<Consultation>> getConsultationsByPatientIdAndDoctorId(String patientId, String doctorId) async {
    final snapshot = await firestore
        .collection('consultations')
        .where('patientId', isEqualTo: patientId)
        .where('doctorId', isEqualTo: doctorId)
        .get();
    return snapshot.docs
        .map((doc) => Consultation.fromMap(doc.data()))
        .toList();
  }

  Future<List<Consultation>> getOldConsultationsByPatientIdAndDoctorId(String patientId, String doctorId) async {
    final now = Timestamp.now();
    final snapshot = await firestore
        .collection('consultations')
        .where('patientId', isEqualTo: patientId)
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isLessThan: now)
        .get();
    return snapshot.docs
        .map((doc) => Consultation.fromMap(doc.data()))
        .toList();
  }

  Future<List<Consultation>> getUpcomingConsultationsByPatientIdAndDoctorId(String patientId, String doctorId) async {
    final now = Timestamp.now();
    final snapshot = await firestore
        .collection('consultations')
        .where('patientId', isEqualTo: patientId)
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isGreaterThan: now)
        .get();
    return snapshot.docs
        .map((doc) => Consultation.fromMap(doc.data()))
        .toList();
  }

  Future<List<Consultation>> getConsultationsByPatientId(String patientId) async {
    final snapshot = await firestore
        .collection('consultations')
        .where('patientId', isEqualTo: patientId)
        .get();
    return snapshot.docs
        .map((doc) => Consultation.fromMap(doc.data()))
        .toList();
  }

  Future<Consultation?> getNextConsultationForDoctor(String doctorId) async {
    try {
      final now = DateTime.now();
      final snapshot = await firestore
          .collection('consultations')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThan: Timestamp.fromDate(now))
          .where('accepted', isEqualTo: true)
          .orderBy('date')
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty
          ? Consultation.fromMap(snapshot.docs.first.data())
          : null;
    } catch (e) {
      print("Mock: Error getting next consultation: $e");
      return null;
    }
  }

  Future<void> updateConsultationField(String id, String field, dynamic value) async {
    try {
      await firestore.collection('consultations').doc(id).update({field: value});
    } catch (e) {
      print("Mock: Error updating field: $e");
    }
  }

  Future<void> deleteConsultation(String id) async {
    try {
      await firestore.collection('consultations').doc(id).delete();
    } catch (e) {
      print("Mock: Error deleting consultation: $e");
    }
  }

  Future<void> updateConsultation(Consultation consultation) async {
    try {
      await firestore.collection('consultations').doc(consultation.consultationId).update(consultation.toMap());
    } catch (e) {
      print("Mock: Error updating consultation: $e");
    }
  }
}