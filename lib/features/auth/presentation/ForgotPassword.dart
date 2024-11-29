import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/AuthController.dart';
import '../../../core/utils/SnackbarHelper.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  ForgotPasswordPage({super.key});

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  // Function to handle password reset
  void _handlePasswordReset(BuildContext context) {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      SnackbarHelper.showError(context, "Email field cannot be empty.");
      return;
    }

    if (!_isValidEmail(email)) {
      SnackbarHelper.showError(context, "Please enter a valid email address.");
      return;
    }

    _authController.resetPassword(email).then((_) {
      SnackbarHelper.showSuccess(
          context, 'Password reset email sent! Check your inbox.');
      Get.offNamed('/login'); // Navigate back to login
    }).catchError((e) {
      SnackbarHelper.showError(context, e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_authController.isLoading.value)
                  const CircularProgressIndicator(),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _handlePasswordReset(context),
                  child: const Text('Send Password Reset Email'),
                ),
                TextButton(
                  onPressed: () {
                    Get.offNamed('/login');
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
