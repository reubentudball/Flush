import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/FlushUser.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  Future<FlushUser?> getFlushUser(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
      await _firestore.collection("User").doc(uid).get();
      if (doc.exists) {
        return FlushUser.fromJson(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching FlushUser for uid $uid: $e");
      return null;
    }
  }

  Future<String> getUserName(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
      await _firestore.collection("User").doc(userId).get();
      if (doc.exists) {
        return doc.data()?['username'] ?? "Anonymous";
      }
      return "Anonymous";
    } catch (e) {
      print("Error fetching username for userId $userId: $e");
      return "Unknown User";
    }
  }
}
