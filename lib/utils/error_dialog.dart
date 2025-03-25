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
        title: Semantics(
          label: 'Error dialog title',
          child: const Text("Something wrong happened"),
        ),
        content: Semantics(
          label: 'Error message',
          child: Text(text),
        ),
        actions: [
          Semantics(
            label: 'OK button',
            child: TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("OK"),
            ),
          ),
        ],
      );
    },
  );
}