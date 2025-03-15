import 'package:flutter/material.dart';
import 'dart:io';

class ExitDialog {
  static Future<bool> showExitDialog(BuildContext context) async {
    bool exitConfirmed = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        title: Container(child: const Text("Exit app")),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () {
              exit(0);
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
