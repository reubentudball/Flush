import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/AuthController.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  bool _rememberMe = false;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  void _handleLogin(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Both fields are required.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!_isValidEmail(email)) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _authController.signIn(email, password, rememberMe: _rememberMe);
  }

  @override
  void initState() {
    super.initState();
    _authController.autoLogin(); // Attempt auto-login on app start
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Center(
                    child: SizedBox(
                      width: 200,
                      height: 150,
                      child: Image.asset('asset/images/FlushLogo.png'),
                    ),
                  ),
                ),
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
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    const Text('Remember Me'),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _handleLogin(context),
                  child: const Text('Login'),
                ),
                if (_authController.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      _authController.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    Get.toNamed('/forgot-password');
                  },
                  child: const Text('Forgot Password?'),
                ),
                TextButton(
                  onPressed: () {
                    Get.toNamed('/sign-up');
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

