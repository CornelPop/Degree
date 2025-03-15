import 'package:flutter/material.dart';
import 'dart:io';

class EditProfileDialog {
  static Future<bool> showExitDialog(BuildContext context) async {
    bool exitConfirmed = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        title: const Text("Attention"),
        content: const Text("Are you sure you want to update your profile?"),
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
