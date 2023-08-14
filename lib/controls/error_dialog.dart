import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('An error has occurred'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: (){ Navigator.of(context).pop(); },
            child: const Text('OK')
          )
        ],
      );
    }
  );
}