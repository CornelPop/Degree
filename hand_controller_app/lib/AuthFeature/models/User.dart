import 'package:pdf/widgets.dart';

class User {
  String uid;
  String createdAt;
  String name;
  String email;
  String password;
  String role;
  String dateOfBirth;
  String phoneNumber;
  String gender;

  User({
    required this.uid,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'createdAt': createdAt,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'gender': gender,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      createdAt: map['createdAt'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      dateOfBirth: map['dateOfBirth'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'],
    );
  }
}

