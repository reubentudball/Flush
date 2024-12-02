import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../models/Bathroom.dart';
import '../models/Comment.dart';
import '../models/Review.dart';

import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class BathroomRepository extends GetxService {
  static BathroomRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final GeoCollectionReference<Map<String, dynamic>> geoCollection =
  GeoCollectionReference(FirebaseFirestore.instance.collection('Bathroom'));


  Future<String> createBathroom(Bathroom bathroom) async {
    try {
      final geoFirePoint = GeoFirePoint(
        GeoPoint(bathroom.location.latitude, bathroom.location.longitude),
      );

      final bathroomData = bathroom.toJson();
      bathroomData['geo']['geohash'] = geoFirePoint.geohash;

      final docRef = await _db.collection("Bathroom").add(bathroomData);
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

  Stream<List<Bathroom>> streamBathrooms() {
    return _db.collection('Bathroom').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Bathroom.fromSnapshot(doc)).toList();
    });
  }


  Future<Bathroom?> getBathroomById(String id) async {
    try {
      final docSnapshot = await _db.collection('Bathroom').doc(id).get();

      if (docSnapshot.exists){
        return Bathroom.fromSnapshot(docSnapshot);
      } else {
        debugPrint("Bathroom with ID $id does not exist");
        return null;
      }

    } catch (e){
      debugPrint("Error fetching bathroom by ID: ${e}");
      return null;
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


  Future<List<Bathroom>> fetchNearbyBathrooms({
    required GeoFirePoint center,
    required double radiusInKm,
  }) async {
    try {
      debugPrint(
          "Fetching bathrooms within $radiusInKm km of center: "
              "latitude: ${center.latitude}, longitude: ${center
              .longitude}, geohash: ${center.geohash}");



      final snapshots = await geoCollection.fetchWithin(
        center: center,
        radiusInKm: radiusInKm,
        field: 'geo',
        strictMode: true,
        geopointFrom: (data) {
          if (data['geo'] != null && data['geo']['geopoint'] != null) {
            final location = data['geo']['geopoint'] as GeoPoint;
            debugPrint(
                "Processing GeoPoint: latitude=${location
                    .latitude}, longitude=${location.longitude}");
            return location;
          } else {
            debugPrint("Geo field is missing or invalid in this document.");
            return GeoPoint(0, 0);
          }
        },
      );

      debugPrint("Fetched ${snapshots.length} documents from Firestore.");

      final bathrooms = snapshots.map((doc) {
        debugPrint("Document ID: ${doc.id}");
        return Bathroom.fromSnapshot(doc);
      }).toList();

      debugPrint(
          "Converted documents to Bathroom objects: ${bathrooms.length}");
      return bathrooms;
    } catch (e, stacktrace) {
      debugPrint("Error fetching nearby bathrooms: $e");
      debugPrint("Stacktrace: $stacktrace");
      return [];
    }
  }

  Future<List<Review>> getReviewsFromBathroom(String bathroomId) async {
    try {
      final snapshot = await _db
          .collection("Bathroom")
          .doc(bathroomId)
          .collection("Reviews")
          .get();

      final Map<String, String> userNameCache = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] ?? "Anonymous";

        if (!userNameCache.containsKey(userId)) {
          final userSnapshot = await _db.collection("Users").doc(userId).get();
          userNameCache[userId] = userSnapshot.data()?['name'] ?? "Unknown User";
        }

        data['userName'] = userNameCache[userId];
      }

      return snapshot.docs.map((doc) => Review.fromSnapshot(doc)).toList();
    } catch (e) {
      log("Error fetching reviews for bathroom $bathroomId: $e");
      rethrow;
    }
  }

  Future<void> addComment(String bathroomId, Comment comment) async {
    try {
      final commentMap = comment.toMap();
      await _db.collection("Bathroom").doc(bathroomId).update({
        'comments': FieldValue.arrayUnion([commentMap]),
      });
      log("Comment added to bathroom: $bathroomId");
    } catch (e) {
      log("Error adding comment to bathroom $bathroomId: $e");
      rethrow;
    }
  }

  Future<List<Comment>> getBathroomComments(String bathroomId) async {
    try {
      final snapshot = await _db.collection("Bathroom").doc(bathroomId).get();
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
      final updatedData = bathroom.toJson();
      updatedData['updatedAt'] = DateTime.now().toUtc().toIso8601String();

      await _db.collection("Bathroom").doc(bathroom.id).update(updatedData);
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


  Future<void> deleteBathroom(String id) async {
    try {
      await _db.collection('Bathroom').doc(id).delete();
      debugPrint("Bathroom with ID $id deleted successfully.");
    } catch (e) {
      debugPrint("Error deleting bathroom with ID $id: $e");
      rethrow;
    }
  }



  Future<List<Bathroom>> refreshBathrooms(List<String> bathroomIds) async {
    try {
      final List<Bathroom> updatedBathrooms = [];

      for (String id in bathroomIds) {
        final docSnapshot = await _db.collection('Bathroom').doc(id).get();

        if (docSnapshot.exists) {
          updatedBathrooms.add(Bathroom.fromSnapshot(docSnapshot));
        } else {
          debugPrint("Bathroom with ID $id does not exist");
        }
      }

      debugPrint("Refreshed ${updatedBathrooms.length} bathrooms.");
      return updatedBathrooms;
    } catch (e) {
      debugPrint("Error refreshing bathrooms: $e");
      return [];
    }
  }
}
