
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
                onPressed: () {
                  context.pop(false);
                },
                child: Text("Cansel")),
            TextButton(
                onPressed: () {
                  context.pop(true);
                },
                child: Text("Log out")),
          ],
        );
      }).then((value) => value ?? false);
}