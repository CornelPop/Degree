import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hand_controller_app/AlertDialogs/AttentionDialogWidget.dart';
import 'package:hand_controller_app/AuthFeature/services/AuthService.dart';
import 'package:hand_controller_app/AlertDialogs/ErrorDialogWidget.dart';
import 'package:hand_controller_app/AuthFeature/services/UserService.dart';

import '../../GlobalThemeData.dart';
import 'SignInScreen.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String role;

  const ProfileCompletionScreen(
      {super.key,
      required this.name,
      required this.email,
      required this.password,
      required this.role});

  @override
  _ProfileCompletionScreenState createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _maxNoOfPatientsController =
      TextEditingController();

  String? _message;
  String? _gender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                height: 220,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors
                        .transparent, // Make border color transparent to show the gradient
                  ),
                ),
                child: Image.asset(
                  "assets/images/logo.png",
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Finish your profile',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: CustomTheme.secondaryColor,
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
                              offset: Offset(0, 0), // Offset of the shadow
                            ),
                          ],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextFormField(
                          enabled: false,
                          readOnly: true,
                          controller: _dateOfBirthController,
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon:
                                Icon(Icons.calendar_month, color: Colors.white),
                            labelStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                            offset: Offset(0, 0), // Offset of the shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    widget.role != 'Patient'
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
                                  color: Colors.black.withOpacity(0.2),
                                  // Shadow color
                                  blurRadius: 20,
                                  // Blur radius
                                  offset: Offset(0, 0), // Offset of the shadow
                                ),
                              ],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextFormField(
                              controller: _specializationController,
                              decoration: InputDecoration(
                                labelText: 'Specialization',
                                prefixIcon:
                                    Icon(Icons.work, color: Colors.white),
                                labelStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : Container(),
                    const SizedBox(height: 10),
                    widget.role != 'Patient'
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
                                  color: Colors.black.withOpacity(0.2),
                                  // Shadow color
                                  blurRadius: 20,
                                  // Blur radiu
                                  offset: Offset(0, 0), // Offset of the shadow
                                ),
                              ],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _maxNoOfPatientsController,
                              decoration: InputDecoration(
                                labelText: 'Maximum number of patients',
                                prefixIcon:
                                    Icon(Icons.add, color: Colors.white),
                                labelStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : Container(),
                    const SizedBox(height: 10),
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
                            offset: Offset(0, 0), // Offset of the shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 0.0),
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
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _gender == 'Male'
                                            ? CustomTheme.accentColor2
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(30),
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
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _gender == 'Female'
                                            ? CustomTheme.accentColor4
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(30),
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
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _gender == 'Other'
                                            ? CustomTheme.accentColor3
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(30),
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
                    const SizedBox(height: 40),
                    Container(
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
                            offset: Offset(0, 0), // Offset of the shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          String errors = '';

                          if (widget.role != 'Patient') {
                            if (_specializationController.text.isEmpty) {
                              errors += 'Please enter your gender.\n';
                            }

                            if (_maxNoOfPatientsController.text.isEmpty) {
                              errors += 'Please enter your max number of patients.\n';
                            }
                          }

                          if (_phoneNumberController.text.isEmpty) {
                            errors += 'Please enter your phoneNumber.\n';
                          }

                          if (_dateOfBirthController.text.isEmpty) {
                            errors += 'Please enter your date of birth.\n';
                          }

                          if (_gender == null) {
                            errors += 'Please select a gender.\n';
                          }

                          if (errors.isNotEmpty) {
                            ErrorDialogWidget(message: errors.trim())
                                .showErrorDialog(context);
                            return;
                          } else {
                            final message = await _authService.register(
                                widget.email,
                                widget.password,
                                widget.name,
                                widget.role,
                                _dateOfBirthController.text,
                                _phoneNumberController.text,
                                _gender!);

                            if (message != null && !message.startsWith('E')) {
                              if (widget.role != 'Patient') {
                                await _userService.updateUserFields(message, {
                                  'specialization':
                                      _specializationController.text,
                                  'maxNoOfPatients':
                                      int.parse(_maxNoOfPatientsController.text),
                                });
                              }

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => SignInScreen()),
                                (Route<dynamic> route) => false,
                              );
                            } else {
                              ErrorDialogWidget(
                                      message: message ?? 'Unknown error')
                                  .showErrorDialog(context);
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
                          'Finish',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "You want to do this later?",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              bool buttonPressed = await AttentionDialog.showExitDialog(context);
                              if (buttonPressed) { print('ajunge');
                                final message = await _authService.register(
                                    widget.email,
                                    widget.password,
                                    widget.name,
                                    widget.role,
                                    '', '', '');

                                if (message != null && !message.startsWith('E')) {
                                  if (widget.role != 'Patient') {
                                    await _userService.updateUserFields(message, {
                                      'specialization': '',
                                      'maxNoOfPatients': ''
                                    });
                                  }

                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => SignInScreen()),
                                        (Route<dynamic> route) => false,
                                  );
                                } else {
                                  ErrorDialogWidget(
                                      message: message ?? 'Unknown error')
                                      .showErrorDialog(context);
                                }
                              }
                            },
                            child: const Text(
                              'Sign in!',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                color: CustomTheme.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_message != null)
                      Text(
                        _message!,
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
