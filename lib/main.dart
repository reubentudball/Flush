import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'features/auth/presentation/LoginPage.dart';
import 'features/auth/presentation/SignUp.dart';
import 'features/auth/presentation/ForgotPassword.dart';
import 'features/bathroom/presentation/HomePage.dart';
import 'core/firebase_options.dart';
import 'features/bathroom/controllers/BathroomController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(BathroomController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flush',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () =>  LoginPage()),
        GetPage(name: '/sign-up', page: () =>  SignUpPage()),
        GetPage(name: '/forgot-password', page: () =>  ForgotPasswordPage()),
        GetPage(name: '/home', page: () => const HomePage()),
      ],
    );
  }
}
