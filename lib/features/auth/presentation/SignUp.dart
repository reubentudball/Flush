import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/AuthController.dart';
import '../../../core/utils/SnackbarHelper.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  SignUpPage({super.key});

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  void _handleSignUp(BuildContext context) {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      SnackbarHelper.showError(context, "All fields are required.");
      return;
    }

    if (!_isValidEmail(email)) {
      SnackbarHelper.showError(context, "Please enter a valid email address.");
      return;
    }

    if (password != confirmPassword) {
      SnackbarHelper.showError(context, "Passwords do not match.");
      return;
    }

    if (password.length < 6) {
      SnackbarHelper.showError(context, "Password must be at least 6 characters long.");
      return;
    }

    _authController
        .signUp(
      email,
      password,
      firstName,
      lastName,
      username,
    )
        .then((_) {
      SnackbarHelper.showSuccess(context, 'Account created successfully!');
      Get.offNamed('/login');
    }).catchError((e) {
      SnackbarHelper.showError(context, e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return SingleChildScrollView(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_authController.isLoading.value)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: CircularProgressIndicator(),
                        ),
                      const Text(
                        'Personal Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Account Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Password',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () => _handleSignUp(context),
                        child: const Text('Sign Up'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Get.offNamed('/login');
                        },
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
