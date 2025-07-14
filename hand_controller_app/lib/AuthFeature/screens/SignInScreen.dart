import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/screens/RegisterScreen.dart';
import 'package:hand_controller_app/AuthFeature/services/SharedPrefService.dart';
import 'package:hand_controller_app/AuthFeature/services/UserService.dart';
import 'package:hand_controller_app/TrainingProgramsFeature/screens/TrainingProgramScreen.dart';

import '../../GlobalThemeData.dart';
import '../services/AuthService.dart';
import '../../AlertDialogs/ErrorDialogWidget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService();
  final UserService userService = UserService();
  final SharedPrefsService sharedPrefsService = SharedPrefsService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _message;
  bool showPass = false;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: signInContentWidget(),
    );
  }

  Widget signInContentWidget() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
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
                border: Border.all(color: Colors.transparent),
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
                    'Welcome Back',
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
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          blurRadius: 20, // Blur radius
                          offset: Offset(0, 0), // Offset of the shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail, color: Colors.white),
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
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
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          blurRadius: 20, // Blur radius
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
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              showPass = !showPass;
                            });
                          },
                          child: Icon(
                            showPass ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                        ),
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      obscureText: !showPass,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        if (_emailController.text.isEmpty) {
                          ErrorDialogWidget(
                                  message: "You must fill the email field")
                              .showErrorDialog(context);
                        } else {
                          await _authService
                              .sendPasswordResetEmail(_emailController.text);
                        }
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: CustomTheme.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Checkbox(
                          checkColor: CustomTheme.secondaryColor,
                          fillColor:
                              MaterialStateProperty.resolveWith((states) {
                            return CustomTheme.accentColor;
                          }),
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value ?? false;
                            });
                          },
                        ),
                        const Text(
                          'Keep me logged in',
                          style: TextStyle(color: CustomTheme.secondaryColor),
                        ),
                      ],
                    ),
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
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          blurRadius: 20, // Blur radius
                          offset: Offset(0, 0), // Offset of the shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
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

                        if (errors.isNotEmpty) {
                          ErrorDialogWidget(message: errors.trim())
                              .showErrorDialog(context);
                          return;
                        }

                        final message = await _authService.signIn(
                          _emailController.text,
                          _passwordController.text,
                        );

                        setState(() {
                          _message = message;
                        });

                        if (message != null && !message.startsWith('E')) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrainingProgramScreen(),
                            ),
                          );

                          sharedPrefsService.storeRememberMe(isChecked);
                        } else {
                          if (message != null) {
                            if (message.contains("INVALID_LOGIN_CREDENTIALS")) {
                              ErrorDialogWidget(
                                      message: "Invalid email or password")
                                  .showErrorDialog(context);
                            } else if (message.contains("all requests")) {
                              ErrorDialogWidget(
                                      message:
                                          "Something went wrong. Try again later.")
                                  .showErrorDialog(context);
                            } else {
                              ErrorDialogWidget(message: message)
                                  .showErrorDialog(context);
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
                        'Login',
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            height: 1,
                            color: CustomTheme.secondaryColor,
                          ),
                        ),
                        const Text(
                          'OR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CustomTheme.secondaryColor,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            height: 1,
                            color: CustomTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    height: 50,
                    width: double.infinity,
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
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          blurRadius: 20, // Blur radius
                          offset: Offset(0, 0), // Offset of the shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    // Padding to display the border
                    child: ElevatedButton(
                      onPressed: () async {
                        if (await _authService.signInWithGoogle() != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TrainingProgramScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        backgroundColor: CustomTheme.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/google_logo.png",
                            fit: BoxFit.cover,
                            width: 25,
                            height: 25,
                          ),
                          SizedBox(width: 10),
                          const Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: CustomTheme.secondaryColor),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Sign up!',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
