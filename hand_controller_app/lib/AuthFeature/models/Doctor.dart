import 'dart:math';

import 'User.dart';

class Doctor extends User {
  String specialization;
  double rating;
  int maxNoOfPatients;

  Doctor({
    required String uid,
    required String createdAt,
    required String name,
    required String email,
    required String password,
    required String role,
    required String dateOfBirth,
    required String phoneNumber,
    required String gender,
    this.specialization = 'Unknown',
    this.rating = 0.0,
    this.maxNoOfPatients = 0,
  }) : super(uid: uid, createdAt: createdAt, gender: gender, name: name, email: email, password: password, role: role, phoneNumber: phoneNumber, dateOfBirth: dateOfBirth);

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    baseMap.addAll({
      'specialization': specialization,
      'rating': rating,
      'maxNoOfPatients': maxNoOfPatients,
    });
    return baseMap;
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      uid: map['uid'] as String,
      createdAt: map['createdAt'],
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      specialization: (map['specialization'] != null && map['specialization'] is String)
          ? map['specialization']
          : 'Unknown',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0.0,
      maxNoOfPatients: (map['maxNoOfPatients'] is int)
          ? map['maxNoOfPatients']
          : int.tryParse(map['maxNoOfPatients']?.toString() ?? '') ?? 0,
      phoneNumber: map['phoneNumber'] as String? ?? '',
      dateOfBirth: map['dateOfBirth'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
    );
  }

}
