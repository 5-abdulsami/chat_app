import 'package:flutter/material.dart';
import 'package:linkup/utils/colors.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: blueColor,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showProgressDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));
  }
}
