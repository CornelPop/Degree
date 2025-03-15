import 'package:flutter/material.dart';
import 'dart:io';

class ErrorDialogWidget {

  final String? message;

  ErrorDialogWidget({Key? key,
    required this.message
  });

  Future<bool> showErrorDialog(BuildContext context) async {
    bool exitConfirmed = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        title: const Text("Error", style: TextStyle(color: Colors.white),),
        content: Text(message!, style: TextStyle(color: Colors.white),),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Ok", style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
    return exitConfirmed;
  }
}
