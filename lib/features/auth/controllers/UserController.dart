import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../data/model/FlushUser.dart';
import '../data/service/UserService.dart';

class UserController extends GetxController {
  final UserService _userService = Get.put(UserService());

  final Rxn<User> firebaseUser = Rxn<User>();
  final Rxn<FlushUser> flushUser = Rxn<FlushUser>();

  @override
  void onInit() {
    super.onInit();
    firebaseUser.value = _userService.getCurrentUser();
    _userService.authStateChanges.listen((user) {
      firebaseUser.value = user;
      if (user != null) {
        fetchFlushUser(user.uid);
      } else {
        flushUser.value = null;
      }
    });
  }

  Future<void> fetchFlushUser(String uid) async {
    try {
      final userData = await _userService.getFlushUser(uid);
      if (userData != null) {
        flushUser.value = userData;
      } else {
        flushUser.value = null;
      }
    } catch (e) {
      print("Failed to fetch FlushUser: $e");
      flushUser.value = null;
    }
  }

  String getFirstName() {
    return flushUser.value?.firstName ?? "Guest";
  }

  String getDisplayName() {
    return firebaseUser.value?.displayName ?? "Guest";
  }

  Future<String> getUserName(String userId) async {
    try {
      return await _userService.getUserName(userId);
    } catch (e) {
      print("Error fetching user name for userId $userId: $e");
      return "Unknown User";
    }
  }
}
