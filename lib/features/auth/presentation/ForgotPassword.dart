import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/AuthController.dart';
import '../../../core/utils/SnackbarHelper.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  ForgotPasswordPage({super.key});

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
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_authController.isLoading.value) const CircularProgressIndicator(),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _authController.resetPassword(_emailController.text).then((_) {
                    SnackbarHelper.showSuccess(context, 'Password reset email sent!');
                  }).catchError((e) {
                    SnackbarHelper.showError(context, e.toString());
                  });
                },
                child: const Text('Send Password Reset Email'),
              ),
              TextButton(
                onPressed: () {
                  Get.offNamed('/login');
                },
                child: const Text('Back to Login'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
