import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
){
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: const Text("something wrong happened"),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: ()
          {
            context.pop();
          },
          child: const Text("OK"),
        )
      ],
    );
  });
}
