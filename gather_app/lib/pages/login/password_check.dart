import 'package:flutter/material.dart';

class PasswordCheck {
  void checkPassword(
      passwordController, passwordConfirmationController, context, signUpPage) {
    if (passwordController.text != passwordConfirmationController.text) {
      // Displays an alert dialog if the passwords do not match
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Passwords do not match'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } else if (passwordController.text.length < 6) {
      // Displays an alert dialog if the passwords do not match
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Password must be at least 6 characters long'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      signUpPage();
    }
  }
}
