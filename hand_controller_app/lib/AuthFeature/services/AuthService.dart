import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hand_controller_app/AuthFeature/services/SharedPrefService.dart';
import 'package:hand_controller_app/AuthFeature/services/UserService.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pdf/widgets.dart';

import '../models/Doctor.dart';
import '../models/Patient.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final UserService userService = UserService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SharedPrefsService sharedPrefsService = SharedPrefsService();

  Future<String?> register(
      String email,
      String password,
      String name,
      String role,
      String dateOfBirth,
      String phoneNumber,
      String gender) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final key = encrypt.Key.fromLength(32);
      final iv = encrypt.IV.fromLength(16);
      final encrypted = encrypt.Encrypter(encrypt.AES(key));

      final encryptedPassword = encrypted.encrypt(password, iv: iv).base64;

      Map<String, dynamic> userMap;

      if (role == 'Doctor' || role == 'Therapist') {
        userMap = Doctor(
          uid: userCredential.user!.uid,
          createdAt: Timestamp.now().toDate().toString(),
          name: name,
          email: email,
          password: encryptedPassword,
          role: role,
          dateOfBirth: dateOfBirth,
          phoneNumber: phoneNumber,
          gender: gender,
        ).toMap();
      } else {
        userMap = Patient(
          uid: userCredential.user!.uid,
          createdAt: Timestamp.now().toDate().toString(),
          name: name,
          email: email,
          password: encryptedPassword,
          role: role,
          dateOfBirth: dateOfBirth,
          phoneNumber: phoneNumber,
          gender: gender,
        ).toMap();
      }

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userMap);

      return userCredential.user!.uid;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      await userService.storeUserUid(userCredential.user!.uid);

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user!.uid).get();
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': userCredential.user!.uid,
          'name': googleUser.displayName,
          'createdAt': Timestamp.now().toDate().toString(),
          'role': 'Patient',
          'email': googleUser.email,
          'password': '',
          'numberBeginnerExercises': 0,
          'numberIntermediateExercises': 0,
          'numberDifficultExercises': 0,
          'timeSpentInWorkouts': 0,
          'accuracyOfExercises': 0.0,
          'doctorId': '',
          'dateOfBirth': '',
          'phoneNumber': '',
          'gender': '',
        });
      }

      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userService.storeUserUid(userCredential.user!.uid);
        print(userCredential.user!.uid);

        return 'User signed in: ${userCredential.user!.email}';
      } else {
        return 'User sign-in failed: User is null.';
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      return 'Error: ${e.toString()}';
    }
  }


  Future<String?> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await sharedPrefsService.storeRememberMe(false);
      return 'User signed out';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String?> deleteAccount() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentReference userDocRef =
            _firestore.collection('users').doc(user.uid);
        CollectionReference completedProgramsRef =
            userDocRef.collection('completedPrograms');
        QuerySnapshot completedProgramsSnapshot =
            await completedProgramsRef.get();

        for (DocumentSnapshot doc in completedProgramsSnapshot.docs) {
          await doc.reference.delete();
        }

        await userDocRef.delete();
        await user.delete();
        await _auth.signOut();

        return 'User deleted';
      } catch (e) {
        return 'Error: ${e.toString()}';
      }
    }
    return 'No user signed in';
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return 'password email sent';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<void> updateUserEmail(String userId, String newEmail, String oldEmail, String encryptedPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('No user is logged in.');
        return;
      }

      final key = encrypt.Key.fromLength(32);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decryptedPassword = encrypter.decrypt64(encryptedPassword, iv: iv);

      AuthCredential credential = EmailAuthProvider.credential(
        email: oldEmail,
        password: decryptedPassword,
      );

      await user.reauthenticateWithCredential(credential);

      await user.verifyBeforeUpdateEmail(newEmail);

      user = FirebaseAuth.instance.currentUser;
      while (!user!.emailVerified) {
        await Future.delayed(const Duration(seconds: 3));
        user = FirebaseAuth.instance.currentUser;
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'email': newEmail,
      });

      print('Email updated successfully.');
    } catch (e) {
      print('Error updating email: $e');
    }
  }

}
