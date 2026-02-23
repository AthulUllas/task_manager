import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TaskSnackbar {
  static final FToast _fToast = FToast();

  static void showSuccess(BuildContext context, String title, String message) {
    _show(
      context,
      message,
      const Color(0xFF03DAC6),
      Icons.check_circle_outline,
    );
  }

  static void showError(BuildContext context, String title, String message) {
    _show(context, message, Colors.redAccent, Icons.error_outline);
  }

  static void showWarning(BuildContext context, String title, String message) {
    _show(context, message, Colors.orangeAccent, Icons.warning_amber_rounded);
  }

  static void showInfo(BuildContext context, String title, String message) {
    _show(context, message, const Color(0xFFBB86FC), Icons.info_outline);
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    _fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: const Color(0xFF1F1B24),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12.0),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );

    _fToast.removeCustomToast();
    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }
}
