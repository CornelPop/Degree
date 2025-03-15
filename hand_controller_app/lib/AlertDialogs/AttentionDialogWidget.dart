import 'package:flutter/material.dart';
import 'dart:io';

import '../AuthFeature/screens/SignInScreen.dart';

class AttentionDialog {
  static Future<bool> showExitDialog(BuildContext context) async {
    bool exitConfirmed = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        title: Container(child: const Text("Attention")),
        content: const Text("Are you sure you want to skip this? The account will be created with missing information "
            "and you can not use all of the functionalities of the app"
            " without it. You can finish this up in the profile section."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("No"),
          ),
        ],
      ),
    );

    return exitConfirmed;
  }
}
