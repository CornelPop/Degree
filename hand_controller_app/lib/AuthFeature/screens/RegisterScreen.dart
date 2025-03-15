import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/screens/ProfileCompletionScreen.dart';
import 'package:hand_controller_app/AuthFeature/services/AuthService.dart';
import 'package:hand_controller_app/AlertDialogs/ErrorDialogWidget.dart';

import '../../GlobalThemeData.dart';
import 'SignInScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _message;
  String? _role;
  bool showPass = false;
  bool showConfirmPass = false;
  bool isPatientOptionChosen = false;

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
                      'Create an account',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: CustomTheme.secondaryColor,
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
                            offset: Offset(0, 0), // Offset of the shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white),
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
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white),
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
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                showPass = !showPass;
                              });
                            },
                            child: showPass
                                ? Icon(Icons.disabled_visible_rounded,
                                    color: Colors.white)
                                : Icon(Icons.remove_red_eye_rounded,
                                    color: Colors.white),
                          ),
                          border: InputBorder.none,
                        ),
                        obscureText: !showPass,
                        style: TextStyle(color: Colors.white),
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
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                showConfirmPass = !showConfirmPass;
                              });
                            },
                            child: showConfirmPass
                                ? Icon(Icons.disabled_visible_rounded,
                                    color: Colors.white)
                                : Icon(Icons.remove_red_eye_rounded,
                                    color: Colors.white),
                          ),
                          border: InputBorder.none,
                        ),
                        obscureText: !showConfirmPass,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Choose you title from the options below:",
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      isPatientOptionChosen = true;
                                      setState(() {
                                        _role = 'Patient';
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _role == 'Patient'
                                            ? CustomTheme.accentColor2
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: _role == 'Patient'
                                              ? Colors.white
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Text(
                                        'Patient',
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
                                        _role = 'Therapist';
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _role == 'Therapist'
                                            ? CustomTheme.accentColor4
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: _role == 'Therapist'
                                              ? Colors.white
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Text(
                                        'Therapist',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      isPatientOptionChosen = false;
                                      setState(() {
                                        _role = 'Doctor';
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _role == 'Doctor'
                                            ? CustomTheme.accentColor3
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: _role == 'Doctor'
                                              ? Colors.white
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Text(
                                        'Doctor',
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
                    const SizedBox(height: 20),
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

                          if (_emailController.text.isEmpty) {
                            errors += 'Please enter your email.\n';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(_emailController.text)) {
                            errors += 'Please enter a valid email.\n';
                          }

                          if (_passwordController.text.isEmpty) {
                            errors += 'Please enter your password.\n';
                          } else if (_passwordController.text.length < 6) {
                            errors +=
                                'Password must be at least 6 characters long.\n';
                          }

                          if (_confirmPasswordController.text.isEmpty) {
                            errors += 'Please confirm your password.\n';
                          } else if (_passwordController.text
                                  .compareTo(_confirmPasswordController.text) !=
                              0) {
                            errors +=
                                'Password and Confirm Password fields are not matched.\n';
                          }

                          if (_nameController.text.isEmpty) {
                            errors += 'Please enter your name.\n';
                          }

                          if (_role == null) {
                            errors += 'Please select a role.\n';
                          }

                          if (errors.isNotEmpty) {
                            ErrorDialogWidget(message: errors.trim())
                                .showErrorDialog(context);
                            return;
                          } else {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => ProfileCompletionScreen(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    name: _nameController.text,
                                    role: _role!,)),
                                  (Route<dynamic> route) => false,
                            );
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
                          'Continue',
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
                            "Already have an account?",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => SignInScreen()),
                                (Route<dynamic> route) => false,
                              );
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
}
