import 'package:flush/features/bathroom/controllers/FilterController.dart';
import 'package:flush/features/bathroom/presentation/BathroomDetails.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'features/auth/presentation/LoginPage.dart';
import 'features/auth/presentation/SignUp.dart';
import 'features/auth/presentation/ForgotPassword.dart';
import 'features/bathroom/controllers/ReportController.dart';
import 'features/bathroom/presentation/HomePage.dart';
import 'core/firebase_options.dart';
import 'features/bathroom/controllers/BathroomController.dart';
import 'features/auth/presentation/ProfilePage.dart';
import 'features/auth/controllers/AuthController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.lazyPut(() => BathroomController());
  Get.put(AuthController());
  Get.lazyPut(() => ReportController());
  Get.put(FilterController());


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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () =>  LoginPage()),
        GetPage(name: '/sign-up', page: () =>  SignUpPage()),
        GetPage(name: '/forgot-password', page: () =>  ForgotPasswordPage()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/profile', page: () => ProfilePage()),
        GetPage(name: '/bathroom-details', page: () => BathroomDetails(bathroom: Get.arguments)),

      ],
    );
  }
}
