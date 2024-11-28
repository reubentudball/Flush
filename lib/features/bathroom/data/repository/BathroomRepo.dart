import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/Bathroom.dart';
import '../models/Comment.dart';
import '../models/Review.dart';

class BathroomRepository extends GetxService {
  static BathroomRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createBathroom(Bathroom bathroom) async {
    try {
      final docRef = await _db.collection("Bathroom").add(bathroom.toJson());
      log("Bathroom created with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      log("Error creating bathroom: $e");
      rethrow;
    }
  }

  Future<void> createReview(String bathroomId, Review review) async {
    try {
      await _db
          .collection("Bathroom")
          .doc(bathroomId)
          .collection("Reviews")
          .add(review.toJson());
      log("Review added to bathroom: $bathroomId");
    } catch (e) {
      log("Error adding review: $e");
      rethrow;
    }
  }

  Future<List<Bathroom>> getAllBathrooms() async {
    try {
      final snapshot = await _db.collection("Bathroom").get();
      final bathrooms =
      snapshot.docs.map((doc) => Bathroom.fromSnapshot(doc)).toList();
      return bathrooms;
    } catch (e) {
      log("Error fetching bathrooms: $e");
      rethrow;
    }
  }

  Future<List<Review>> getReviewsFromBathroom(String bathroomId) async {
    try {
      final snapshot = await _db
          .collection("Bathroom")
          .doc(bathroomId)
          .collection("Reviews")
          .get();
      final reviews =
      snapshot.docs.map((doc) => Review.fromSnapshot(doc)).toList();
      return reviews;
    } catch (e) {
      log("Error fetching reviews for bathroom $bathroomId: $e");
      rethrow;
    }
  }

  Future<List<Comment>> getBathroomComments(String bathroomId) async {
    try {
      final snapshot =
      await _db.collection("Bathroom").doc(bathroomId).get();
      if (snapshot.exists) {
        final commentsData =
        List<Map<String, dynamic>>.from(snapshot.data()?['comments'] ?? []);
        final comments = commentsData.map((data) => Comment.fromJson(data)).toList();
        return comments;
      } else {
        log("Bathroom document $bathroomId does not exist");
        return [];
      }
    } catch (e) {
      log("Error fetching comments for bathroom $bathroomId: $e");
      rethrow;
    }
  }

  Future<void> updateBathroom(Bathroom bathroom) async {
    try {
      await _db.collection("Bathroom").doc(bathroom.id).update(bathroom.toJson());
      log("Bathroom ${bathroom.id} updated successfully");
    } catch (e) {
      log("Error updating bathroom ${bathroom.id}: $e");
      rethrow;
    }
  }

  Future<void> updateBathroomsBatch(List<Bathroom> bathrooms) async {
    final batch = _db.batch();
    try {
      for (var bathroom in bathrooms) {
        final docRef = _db.collection("Bathroom").doc(bathroom.id);
        batch.update(docRef, bathroom.toJson());
      }
      await batch.commit();
      log("Batch update successful for ${bathrooms.length} bathrooms");
    } catch (e) {
      log("Error during batch update: $e");
      rethrow;
    }
  }
}
