import 'package:cloud_firestore/cloud_firestore.dart';

class Consultation {
  String consultationId;
  String doctorId;
  String patientId;
  DateTime date;
  String title;
  String notes;
  String treatmentPlan;
  String location;
  bool accepted;

  Consultation({
    required this.consultationId,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.title,
    required this.notes,
    required this.treatmentPlan,
    this.accepted = false,
    required this.location
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'title': title,
      'notes': notes,
      'accepted': accepted,
      'location': location,
      'treatmentPlan': treatmentPlan,
      'consultationId': consultationId,
      'doctorId': doctorId,
      'patientId': patientId,
    };
  }

  factory Consultation.fromMap(Map<String, dynamic> map) {
    return Consultation(
      consultationId: map['consultationId'],
      patientId: map['patientId'],
      doctorId: map['doctorId'],
      location: map['location'],
      accepted: map['accepted'],
      date: (map['date'] as Timestamp).toDate(),
      title: map['title'],
      notes: map['notes'],
      treatmentPlan: map['treatmentPlan'] ?? '',
    );
  }
}
