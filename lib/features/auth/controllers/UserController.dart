import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/model/FlushUser.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rxn<User> firebaseUser = Rxn<User>();
  final Rxn<FlushUser> flushUser = Rxn<FlushUser>();

  @override
  void onInit() {
    super.onInit();
    firebaseUser.value = _auth.currentUser;
    _auth.authStateChanges().listen((user) {
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
      final DocumentSnapshot<Map<String, dynamic>> doc =
      await _firestore.collection("User").doc(uid).get();
      if (doc.exists) {
        flushUser.value = FlushUser.fromJson(doc.id, doc.data()!);
      } else {
        flushUser.value = null;
      }
    } catch (e) {
      print("Failed to fetch FlushUser: $e");
      flushUser.value = null;
    }
  }

  String getFirstName() {
    if (flushUser.value != null) {
      return flushUser.value!.firstName;
    }
    return "Guest";
  }

  String getDisplayName() {
    return firebaseUser.value?.displayName ?? "Guest";
  }
}
