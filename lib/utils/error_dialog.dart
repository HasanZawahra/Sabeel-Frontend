import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners for the dialog
        ),
        backgroundColor: const Color(0xFFFDEDED), // Light red background for error
        title: Semantics(
          label: 'Error dialog title',
          child: const Text(
            "Something went wrong",
            style: TextStyle(
              fontSize: 22, // Larger font size for the title
              fontWeight: FontWeight.bold, // Bold text for emphasis
              color: Colors.red, // Red text color for the title
            ),
          ),
        ),
        content: Semantics(
          label: 'Error message',
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16, // Standard font size for the message
              color: Colors.black87, // Darker text color for better readability
            ),
          ),
        ),
        actions: [
          Semantics(
            label: 'OK button',
            child: TextButton(
              onPressed: () {
                context.pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // White text for the button
                backgroundColor: Colors.red, // Red background for the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners for the button
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ), // Padding for a larger button
              ),
              child: const Text(
                "OK",
                style: TextStyle(
                  fontSize: 16, // Font size for the button text
                  fontWeight: FontWeight.bold, // Bold text for emphasis
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}