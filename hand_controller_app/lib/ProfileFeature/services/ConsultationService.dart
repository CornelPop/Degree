import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Consultation.dart';

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

  Future<List<Consultation>> getOldConsultationsByPatientIdAndDoctorId(String patientId, String doctorId) async {
    try {
      Timestamp now = Timestamp.now();

      QuerySnapshot querySnapshot = await firestore
          .collection('consultations')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isLessThan: now)
          .get();

      return querySnapshot.docs
          .map((doc) => Consultation.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting old consultations: $e");
      return [];
    }
  }

  Future<List<Consultation>> getUpcomingConsultationsByPatientIdAndDoctorId(String patientId, String doctorId) async {
    try {
      Timestamp now = Timestamp.now();

      QuerySnapshot querySnapshot = await firestore
          .collection('consultations')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThan: now)
          .get();

      return querySnapshot.docs
          .map((doc) => Consultation.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting upcoming consultations: $e");
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

  Future<Consultation?> getNextConsultationForDoctor(String doctorId) async {
    try {
      DateTime now = DateTime.now();

      QuerySnapshot querySnapshot = await firestore
          .collection('consultations')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThan: now)
          .where('accepted', isEqualTo: true)
          .orderBy('date')
          .limit(1)
          .get();

      return Consultation.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      print("Error getting next consultation for doctor: $e");
      return null;
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

  Future<void> updateConsultationField(String consultationId, String field, dynamic value) async {
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
