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
    _authController.autoLogin().then((_) {
      if (_authController.currentUser == null) {
        debugPrint("No valid user logged in.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Obx(() {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset('asset/images/FlushLogo.png'),
                  ),
                ),
                const SizedBox(height: 40),
                if (_authController.isLoading.value)
                  const CircularProgressIndicator(),
                if (!_authController.isLoading.value) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  if (_authController.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        _authController.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Get.toNamed('/forgot-password');
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed('/sign-up');
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }
}

