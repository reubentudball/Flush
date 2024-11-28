import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/AuthController.dart';
import '../../../core/utils/SnackbarHelper.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_passwordController.text == _confirmPasswordController.text) {
                    _authController.signUp(
                      _emailController.text,
                      _passwordController.text,
                    ).then((_) {
                      SnackbarHelper.showSuccess(context, 'Account created successfully!');
                    }).catchError((e) {
                      SnackbarHelper.showError(context, e.toString());
                    });
                  } else {
                    SnackbarHelper.showError(context, 'Passwords do not match');
                  }
                },
                child: const Text('Sign Up'),
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
