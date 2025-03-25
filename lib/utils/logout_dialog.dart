import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Semantics(
          label: 'Logout dialog title',
          child: const Text('Log out'),
        ),
        content: Semantics(
          label: 'Logout confirmation message',
          child: const Text('Are you sure you want to log out?'),
        ),
        actions: [
          Semantics(
            label: 'Cancel button',
            child: TextButton(
              onPressed: () {
                context.pop(false);
              },
              child: const Text("Cancel"),
            ),
          ),
          Semantics(
            label: 'Log out button',
            child: TextButton(
              onPressed: () {
                context.pop(true);
              },
              child: const Text("Log out"),
            ),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}