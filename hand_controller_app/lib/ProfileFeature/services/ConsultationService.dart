import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/MedicalHistory.dart';

class ConsultationService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Consultation>> getConsultationsByPatientIdAndDoctorId(String patientId, String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('consultations')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: doctorId)
          .get();

      return querySnapshot.docs
          .map((doc) => Consultation.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting consultations: $e");
      return [];
    }
  }

  Future<List<Consultation>> getConsultationsByPatientId(String patientId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('consultations')
          .where('patientId', isEqualTo: patientId)
          .get();

      return querySnapshot.docs
          .map((doc) => Consultation.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting consultations: $e");
      return [];
    }
  }

  Future<void> addConsultation(Consultation consultation) async {
    try {
      DocumentReference docRef = await firestore
          .collection('consultations')
          .add(consultation.toMap());

      await updateConsultationField(docRef.id, 'consultationId', docRef.id);
    } catch (e) {
      print("Error adding consultation: $e");
    }
  }

  Future<void> updateConsultationField(String consultationId, String field, String value) async {
    try {
      await firestore.collection('consultations').doc(consultationId).update({field: value});
    } catch (e) {
      print("Error updating consultation: $e");
    }
  }

  Future<void> deleteConsultation(String consultationId) async {
    try {
      await firestore.collection('consultations').doc(consultationId).delete();
    } catch (e) {
      print("Error deleting consultation: $e");
    }
  }

  Future<void> updateConsultation(Consultation consultation) async {
    try {
      await firestore.collection('consultations').doc(consultation.consultationId).update(consultation.toMap());
    } catch (e) {
      print("Error updating consultation: $e");
    }
  }
}
