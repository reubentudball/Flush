import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flush/features/auth/data/model/FlushUser.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<FlushUser?> getFlushUser() async {
    try {
      final User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw Exception("No authenticated user found");
      }

      final DocumentSnapshot<Map<String, dynamic>> doc =
      await _firestore.collection("User").doc(firebaseUser.uid).get();

      if (!doc.exists) {
        throw Exception("User data not found in Firestore");
      }

      return FlushUser.fromJson(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch user data: ${e.toString()}');
    }
  }

  Future<User?> signUp(String email, String password, String firstName, String lastName, String username) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      final FlushUser newUser = FlushUser(
        id: uid,
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        createdAt: DateTime.now(),
      );

      await _firestore.collection("User").doc(uid).set(newUser.toJson());

      return userCredential.user;
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
