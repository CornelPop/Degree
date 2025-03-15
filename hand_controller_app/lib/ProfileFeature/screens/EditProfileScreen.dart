import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hand_controller_app/AlertDialogs/EditProfileDialog.dart';
import 'package:hand_controller_app/AlertDialogs/ErrorDialogWidget.dart';
import 'package:hand_controller_app/AuthFeature/models/Patient.dart';
import 'package:hand_controller_app/AuthFeature/screens/SignInScreen.dart';
import 'package:hand_controller_app/AuthFeature/services/AuthService.dart';
import 'package:hand_controller_app/AuthFeature/services/UserService.dart';
import 'package:hand_controller_app/ProfileFeature/screens/ProfileScreen.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/EntireMedicalHistoryScreen.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import '../../AuthFeature/models/Doctor.dart';
import '../../GlobalThemeData.dart';

class EditProfileScreen extends StatefulWidget {
  final Patient patient;
  final Doctor doctor;

  const EditProfileScreen({
    super.key,
    required this.patient,
    required this.doctor,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService userService = UserService();

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _maxNoOfPatientsController =
      TextEditingController();

  String? _gender;

  @override
  void initState() {
    super.initState();

    if (widget.doctor.uid == '') {
      _phoneNumberController.text = widget.patient.phoneNumber;
      _dateOfBirthController.text = widget.patient.dateOfBirth;
      _nameController.text = widget.patient.name;
      _emailController.text = widget.patient.email;
      _gender = widget.patient.gender;
    }

    if (widget.patient.uid == '') {
      _phoneNumberController.text = widget.doctor.phoneNumber;
      _dateOfBirthController.text = widget.doctor.dateOfBirth;
      _nameController.text = widget.doctor.name;
      _emailController.text = widget.doctor.email;
      _gender = widget.doctor.gender;
      _specializationController.text = widget.doctor.specialization;
      _maxNoOfPatientsController.text = widget.doctor.maxNoOfPatients.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            height: kToolbarHeight + 20,
          ),
          Column(
            children: [
              AppBarWidget(leadingIcon: Icons.arrow_back,),
              Expanded(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CustomTheme.mainColor2,
                            CustomTheme.mainColor
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              const Text(
                                'Edit profile',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: CustomTheme.secondaryColor,
                                ),
                              ),
                              SizedBox(height: 30),
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      CustomTheme.accentColor4,
                                      CustomTheme.accentColor2
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      // Shadow color
                                      blurRadius: 20,
                                      // Blur radius
                                      offset:
                                          Offset(0, 0), // Offset of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    prefixIcon: Icon(Icons.account_circle,
                                        color: Colors.white),
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      CustomTheme.accentColor4,
                                      CustomTheme.accentColor2
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      // Shadow color
                                      blurRadius: 20,
                                      // Blur radius
                                      offset:
                                          Offset(0, 0), // Offset of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon:
                                        Icon(Icons.email, color: Colors.white),
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 20),
                              InkWell(
                                onTap: () async {
                                  _selectDate(context);
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        CustomTheme.accentColor4,
                                        CustomTheme.accentColor2
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        // Shadow color
                                        blurRadius: 20,
                                        // Blur radius
                                        offset: Offset(
                                            0, 0), // Offset of the shadow
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: TextFormField(
                                    enabled: false,
                                    readOnly: true,
                                    controller: _dateOfBirthController,
                                    decoration: InputDecoration(
                                      labelText: 'Date of Birth',
                                      prefixIcon: Icon(Icons.calendar_month,
                                          color: Colors.white),
                                      border: InputBorder.none,
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                    ),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      CustomTheme.accentColor4,
                                      CustomTheme.accentColor2
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset:
                                          Offset(0, 0), // Offset of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: _phoneNumberController,
                                  decoration: InputDecoration(
                                    labelText: 'Phone',
                                    prefixIcon:
                                        Icon(Icons.phone, color: Colors.white),
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 20),
                              widget.doctor.uid != ''
                                  ? Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            CustomTheme.accentColor4,
                                            CustomTheme.accentColor2
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 20,
                                            offset: Offset(
                                                0, 0), // Offset of the shadow
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: TextFormField(
                                        controller: _specializationController,
                                        decoration: InputDecoration(
                                          labelText: 'Specialization',
                                          prefixIcon: Icon(Icons.work,
                                              color: Colors.white),
                                          border: InputBorder.none,
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                        ),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  : Container(),
                              const SizedBox(height: 20),
                              widget.doctor.uid != ''
                                  ? Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      CustomTheme.accentColor4,
                                      CustomTheme.accentColor2
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: Offset(
                                          0, 0),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _maxNoOfPatientsController,
                                  decoration: const InputDecoration(
                                    labelText: 'Max Number of Patients',
                                    prefixIcon: Icon(Icons.add,
                                        color: Colors.white),
                                    border: InputBorder.none,
                                    labelStyle:
                                    TextStyle(color: Colors.white),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                                  : Container(),
                              const SizedBox(height: 20),
                              const Text(
                                "Choose you gender from the options below:",
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      CustomTheme.accentColor4,
                                      CustomTheme.accentColor2
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      // Shadow color
                                      blurRadius: 20,
                                      // Blur radius
                                      offset:
                                          Offset(0, 0), // Offset of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 0.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _gender = 'Male';
                                                  print('male');
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: _gender == 'Male'
                                                      ? CustomTheme.accentColor2
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  border: Border.all(
                                                    color: _gender == 'Male'
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                                child: Text(
                                                  ' Male ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _gender = 'Female';
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: _gender == 'Female'
                                                      ? CustomTheme.accentColor4
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  border: Border.all(
                                                    color: _gender == 'Female'
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Female',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _gender = 'Other';
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: _gender == 'Other'
                                                      ? CustomTheme.accentColor3
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  border: Border.all(
                                                    color: _gender == 'Other'
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Other',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      CustomTheme.accentColor4,
                                      CustomTheme.accentColor2
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      // Shadow color
                                      blurRadius: 20,
                                      // Blur radius
                                      offset:
                                          Offset(0, 0), // Offset of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_emailController.text.isEmpty) {
                                      ErrorDialogWidget(
                                              message:
                                                  "You must fill the email field")
                                          .showErrorDialog(context);
                                    } else {
                                      await _authService.sendPasswordResetEmail(
                                          _emailController.text);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shadowColor: Colors.transparent,
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Icon(Icons.lock),
                                      Text(
                                        'Change Password',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(Icons.lock)
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      CustomTheme.accentColor4,
                                      CustomTheme.accentColor2
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      // Shadow color
                                      blurRadius: 20,
                                      // Blur radius
                                      offset:
                                          Offset(0, 0), // Offset of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    print('object');

                                    String errors = '';
                                    if (_emailController.text.isEmpty) {
                                      errors += 'Please enter an email\n';
                                    }

                                    if (_dateOfBirthController.text.isEmpty) {
                                      errors +=
                                          'Please enter a date of birth\n';
                                    }

                                    if (_phoneNumberController.text.isEmpty) {
                                      errors += 'Please enter a phone number\n';
                                    }

                                    if (_nameController.text.isEmpty) {
                                      errors += 'Please enter a name\n';
                                    }

                                    if (_gender == '') {
                                      errors += 'Please choose the gender';
                                    }

                                    if (errors.isNotEmpty) {
                                      ErrorDialogWidget(message: errors.trim())
                                          .showErrorDialog(context);
                                      return;
                                    } else {
                                      bool buttonPressed = await EditProfileDialog.showExitDialog(context);
                                      if (buttonPressed) {
                                        if (widget.doctor.uid == '') {
                                          await userService.updateUserFields(
                                              widget.patient.uid,
                                              {
                                                'name': _nameController.text,
                                                'dateOfBirth': _dateOfBirthController.text,
                                                'phoneNumber': _phoneNumberController.text,
                                                'gender': _gender
                                              });

                                          if (widget.patient.email != _emailController.text) {

                                            await _authService.updateUserEmail(widget.patient.uid, _emailController.text, widget.patient.email, widget.patient.password);
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SignInScreen(),
                                              ),
                                                  (route) => false,
                                            );
                                          }

                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProfileScreen(),
                                            ),
                                                (route) => false,
                                          );
                                        } else if (widget.patient.uid == '') {
                                          await userService.updateUserFields(
                                              widget.doctor.uid,
                                              {
                                                'name': _nameController.text,
                                                'dateOfBirth': _dateOfBirthController.text,
                                                'phoneNumber': _phoneNumberController.text,
                                                'gender': _gender,
                                                'specialization': _specializationController.text,
                                                'maxNoOfPatients': int.parse(_maxNoOfPatientsController.text),
                                              });

                                          if (widget.doctor.email != _emailController.text) {

                                            await _authService.updateUserEmail(widget.doctor.uid, _emailController.text, widget.doctor.email, widget.doctor.password);
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SignInScreen(),
                                              ),
                                                  (route) => false,
                                            );
                                          }

                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProfileScreen(),
                                            ),
                                                (route) => false,
                                          );
                                        }
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shadowColor: Colors.transparent,
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Update',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      ))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      String dateString = pickedDate.toString().split(' ')[0];

      setState(() {
        _dateOfBirthController.text = dateString;
      });
    }
  }

}
