import 'package:flutter/material.dart';

class SnackBarUtils {
  SnackBarUtils._();

  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Clear existing SnackBars to prevent queuing
    scaffoldMessenger.removeCurrentSnackBar();
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating, // Modern floating style
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.green,
    );
  }
}
