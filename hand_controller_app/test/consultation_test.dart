import 'package:flutter_test/flutter_test.dart';
import 'package:hand_controller_app/ProfileFeature/models/Consultation.dart';
import 'package:hand_controller_app/ProfileFeature/services/mock_consultation_service.dart';

void main() {
  late MockConsultationService service;

  setUp(() {
    service = MockConsultationService();
  });

  test('addConsultation adds consultation correctly', () async {
    final consultation = createConsultation();
    await service.addConsultation(consultation);
    final result = await service.getConsultationsByPatientId(consultation.patientId);
    expect(result.length, 1);
    expect(result.first.patientId, equals(consultation.patientId));
  });

  test('getConsultationsByPatientIdAndDoctorId returns correct consultations', () async {
    await service.addConsultation(createConsultation(patientId: 'p1', doctorId: 'd1'));
    await service.addConsultation(createConsultation(patientId: 'p2', doctorId: 'd1'));
    final result = await service.getConsultationsByPatientIdAndDoctorId('p1', 'd1');
    expect(result.length, 1);
  });

  test('getOldConsultationsByPatientIdAndDoctorId returns past consultations', () async {
    final oldDate = DateTime.now().subtract(Duration(days: 3));
    await service.addConsultation(createConsultation(date: oldDate));
    final result = await service.getOldConsultationsByPatientIdAndDoctorId('p1', 'd1');
    expect(result.length, 1);
  });

  test('getUpcomingConsultationsByPatientIdAndDoctorId returns future consultations', () async {
    final futureDate = DateTime.now().add(Duration(days: 3));
    await service.addConsultation(createConsultation(date: futureDate));
    final result = await service.getUpcomingConsultationsByPatientIdAndDoctorId('p1', 'd1');
    expect(result.length, 1);
  });

  test('getNextConsultationForDoctor returns next accepted consultation', () async {
    final futureDate = DateTime.now().add(Duration(days: 2));
    await service.addConsultation(createConsultation(date: futureDate, accepted: true));
    final result = await service.getNextConsultationForDoctor('d1');
    expect(result, isNotNull);
    expect(result?.accepted, true);
  });

  test('updateConsultationField updates a field correctly', () async {
    await service.addConsultation(createConsultation());
    final result = await service.getConsultationsByPatientId('p1');
    final id = result.first.consultationId;
    await service.updateConsultationField(id, 'title', 'Updated');
    final updated = await service.getConsultationsByPatientId('p1');
    expect(updated.first.title, 'Updated');
  });

  test('deleteConsultation removes consultation', () async {
    await service.addConsultation(createConsultation());
    final result = await service.getConsultationsByPatientId('p1');
    final id = result.first.consultationId;
    await service.deleteConsultation(id);
    final after = await service.getConsultationsByPatientId('p1');
    expect(after.isEmpty, true);
  });

  test('updateConsultation updates consultation fully', () async {
    await service.addConsultation(createConsultation());
    final result = await service.getConsultationsByPatientId('p1');
    final original = result.first;
    final updated = Consultation(
      consultationId: original.consultationId,
      patientId: original.patientId,
      doctorId: original.doctorId,
      date: original.date,
      title: 'Updated Title',
      notes: 'Updated Notes',
      treatmentPlan: 'Updated Plan',
      location: 'Updated Location',
      accepted: true,
    );
    await service.updateConsultation(updated);
    final after = await service.getConsultationsByPatientId('p1');
    expect(after.first.title, 'Updated Title');
    expect(after.first.accepted, true);
  });
}

Consultation createConsultation({
  String id = '',
  String patientId = 'p1',
  String doctorId = 'd1',
  String title = 'Checkup',
  String notes = 'Initial notes',
  String treatmentPlan = 'Initial plan',
  String location = 'Room 101',
  bool accepted = false,
  DateTime? date,
}) {
  final now = date ?? DateTime.now();
  return Consultation(
    consultationId: id,
    patientId: patientId,
    doctorId: doctorId,
    title: title,
    notes: notes,
    treatmentPlan: treatmentPlan,
    location: location,
    accepted: accepted,
    date: now,
  );
}