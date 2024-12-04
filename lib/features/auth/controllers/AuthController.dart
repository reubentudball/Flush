import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../data/service/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'UserController.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  User? get currentUser => _authService.getCurrentUser();

  Future<void> signIn(String email, String password, {bool rememberMe = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        if (rememberMe) {
          await _saveCredentials(email, password);
        } else {
          await _clearCredentials();
        }

        Get.offAllNamed('/home');
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> autoLogin() async {
    try {
      final credentials = await _getSavedCredentials();
      if (credentials != null) {
        final email = credentials['email'];
        final password = credentials['password'];
        if (email != null && password != null) {
          await signIn(email, password, rememberMe: true);
        }
      }
    } catch (e) {
      debugPrint("Auto-login failed: $e");
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
  }

  Future<Map<String, String>?> _getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }


  Future<void> signUp(String email, String password, String firstName, String lastName, String username) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _authService.signUp(email, password, firstName, lastName, username);
      Get.offNamed('/login'); // Navigate to login on success
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<void> signOut() async {
    try {
      await _clearCredentials();
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }


  Future<void> updateUsername(String username) async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        await user.updateDisplayName(username);
        await user.reload(); // Refresh user information
      }
    } catch (e) {
      throw Exception("Failed to update username: $e");
    } finally {}
  }

  Future<void> deleteAccount() async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      throw Exception("Failed to delete account: $e");
    } finally {}
  }

}
