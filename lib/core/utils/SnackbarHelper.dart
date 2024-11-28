import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarHelper {
  // Show a success message
  static void showSuccess(BuildContext context, String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16.0),
      duration: const Duration(seconds: 3),
    );
  }

  // Show an error message
  static void showError(BuildContext context, String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16.0),
      duration: const Duration(seconds: 3),
    );
  }

  // Show a warning message
  static void showWarning(BuildContext context, String message) {
    Get.snackbar(
      'Warning',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16.0),
      duration: const Duration(seconds: 3),
    );
  }
}
