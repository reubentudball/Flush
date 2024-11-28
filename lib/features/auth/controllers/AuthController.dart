import 'package:get/get.dart';
import '../data/AuthService.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Reactive state for managing loading and errors
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // Sign in logic
  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        Get.offNamed('/home'); // Navigate to HomePage
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Sign up logic
  Future<void> signUp(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authService.signUp(email, password);
      if (user != null) {
        Get.offNamed('/home'); // Navigate to HomePage
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password logic
  Future<void> resetPassword(String email) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _authService.resetPassword(email);
      Get.back(); // Return to the login page
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out logic
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/login'); // Navigate to LoginPage
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }
}
