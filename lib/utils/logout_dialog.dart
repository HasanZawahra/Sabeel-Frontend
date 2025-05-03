import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners for the dialog
        ),
        backgroundColor: const Color(0xFFF8F9FA), // Light background color
        title: Semantics(
          label: 'Logout dialog title',
          child: const Text(
            'Log out',
            style: TextStyle(
              fontSize: 22, // Larger font size for the title
              fontWeight: FontWeight.bold, // Bold text for emphasis
              color: Colors.black, // Black text color
            ),
          ),
        ),
        content: Semantics(
          label: 'Logout confirmation message',
          child: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              fontSize: 16, // Standard font size for the message
              color: Colors.black54, // Slightly lighter text color
            ),
          ),
        ),
        actions: [
          Semantics(
            label: 'Cancel button',
            child: TextButton(
              onPressed: () {
                context.pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 118, 116, 116), // Grey text for the cancel button
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          Semantics(
            label: 'Log out button',
            child: TextButton(
              onPressed: () {
                context.pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                backgroundColor: Color.fromARGB(255, 239, 73, 73),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners for the button
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold, // Bold text for emphasis
                ),
                shadowColor: Colors.black.withOpacity(0.5), // Shadow effect
                elevation: 5, // Elevation for the button
              ),
              child: const Text(
                "Log out",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Bold text for emphasis
              ),
            ),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}