import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));
  }
}
