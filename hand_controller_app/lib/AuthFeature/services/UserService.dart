import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hand_controller_app/AuthFeature/models/Doctor.dart';
import 'package:hand_controller_app/AuthFeature/models/Patient.dart';
import 'package:hand_controller_app/ProfileFeature/models/Consultation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ProfileFeature/models/Rating.dart';
import '../../TrainingProgramsFeature/models/TrainingProgram.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserField(
      String uid, String fieldName, dynamic newValue) async {
    await _firestore.collection('users').doc(uid).update({fieldName: newValue});
  }

  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    await _firestore.collection('users').doc(uid).update(fields);
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(uid).get();
      if (documentSnapshot.exists) {
        return documentSnapshot.data() as Map<String, dynamic>;
      } else {
        print('User does not exist in Firestore.');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<Patient?> getPatientData(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
      await _firestore.collection('users').doc(uid).get();
      if (documentSnapshot.exists) {
        return Patient.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      } else {
        print('User does not exist in Firestore.');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<Doctor?> getDoctorData(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
      await _firestore.collection('users').doc(uid).get();
      if (documentSnapshot.exists) {
        return Doctor.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      } else {
        print('User does not exist in Firestore.');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> storeUserUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', uid);
  }

  Future<String?> getUserUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  Future<List<dynamic>> getUsersByRoles(List<String> roles) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', whereIn: roles)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (roles.contains('Doctor') && data['role'] == 'Doctor' || roles.contains('Therapist') && data['role'] == 'Therapist') {
          return Doctor.fromMap(data);
        } else if (roles.contains('Patient') && data['role'] == 'Patient') {
          return Patient.fromMap(data);
        }

        return data;
      }).toList();
    } catch (e) {
      print('Error fetching users by roles: $e');
      return [];
    }
  }


  Future<List<Patient>> getPatientsByDoctorId(String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Patient')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Patient.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error fetching patients by doctorId: $e');
      return [];
    }
  }


  Future<String?> getUserRoleByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      Map<String, dynamic> data =
          querySnapshot.docs.first.data() as Map<String, dynamic>;
      return data['role'] as String?;
    } catch (e) {
      print('Error fetching user role by email: $e');
      return null;
    }
  }
}
