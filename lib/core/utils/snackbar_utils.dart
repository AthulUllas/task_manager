import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TaskSnackbar {
  static void showSuccess(BuildContext context, String title, String message) {
    _show(message, Colors.green);
  }

  static void showError(BuildContext context, String title, String message) {
    _show(message, Colors.redAccent);
  }

  static void showWarning(BuildContext context, String title, String message) {
    _show(message, Colors.orangeAccent);
  }

  static void showInfo(BuildContext context, String title, String message) {
    _show(message, Colors.blueAccent);
  }

  static void _show(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
