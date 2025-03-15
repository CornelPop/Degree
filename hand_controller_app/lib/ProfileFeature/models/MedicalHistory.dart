class Consultation {
  String consultationId;
  String doctorId;
  String patientId;
  String date;
  String title;
  String notes;
  String treatmentPlan;

  Consultation({
    required this.consultationId,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.title,
    required this.notes,
    required this.treatmentPlan,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'title': title,
      'notes': notes,
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
      date: map['date'],
      title: map['title'],
      notes: map['notes'],
      treatmentPlan: map['treatmentPlan'] ?? '',
    );
  }
}
