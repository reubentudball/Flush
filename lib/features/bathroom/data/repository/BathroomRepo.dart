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

  Future<void> testGeoPoints() async {
    final geoCollection = GeoCollectionReference<Map<String, dynamic>>(
      FirebaseFirestore.instance.collection('Bathroom'),
    );

    // Define a test center point (replace with a known location)
    final GeoFirePoint testCenter = GeoFirePoint(
      GeoPoint(43.469065, -79.70004), // Replace with coordinates near your data
    );

    // Fetch all documents within a large radius (e.g., 50 km)
    try {
      final documents = await geoCollection.fetchWithin(
        center: testCenter,
        radiusInKm: 50.0, // Large radius to ensure results
        field: 'location',
        geopointFrom: (data) {
          // Debug: Log the raw document data
          debugPrint("Raw data from document: $data");

          if (data.containsKey('location')) {
            final location = data['location'] as GeoPoint;
            debugPrint(
              "Found GeoPoint: latitude=${location.latitude}, longitude=${location.longitude}",
            );
            return location;
          } else {
            debugPrint("No GeoPoint found in this document.");
            return GeoPoint(0, 0); // Dummy GeoPoint for missing data
          }
        },
      );

      // Log the number of documents retrieved
      debugPrint("Total documents retrieved: ${documents.length}");
      for (var doc in documents) {
        debugPrint("Document ID: ${doc.id}, Data: ${doc.data()}");
      }
    } catch (e, stacktrace) {
      debugPrint("Error during testGeoPoints: $e");
      debugPrint("Stacktrace: $stacktrace");
    }
  }


  Future<List<Bathroom>> fetchNearbyBathrooms({
    required GeoFirePoint center,
    required double radiusInKm,
  }) async {
    try {
      debugPrint(
          "Fetching bathrooms within $radiusInKm km of center: "
              "latitude: ${center.latitude}, longitude: ${center.longitude}, geohash: ${center.geohash}");

      // Test GeoPoints to ensure documents exist (optional for debugging)
      await testGeoPoints();

      final snapshots = await geoCollection.fetchWithin(
        center: center,
        radiusInKm: radiusInKm,
        field: 'geo', // Specify the full path to the geopoint
        geopointFrom: (data) {
          // Access the geopoint directly
          if (data['geo'] != null && data['geo']['geopoint'] != null) {
            final location = data['geo']['geopoint'] as GeoPoint;
            debugPrint(
                "Processing GeoPoint: latitude=${location.latitude}, longitude=${location.longitude}");
            return location;
          } else {
            debugPrint("Geo field is missing or invalid in this document.");
            return GeoPoint(0, 0); // Fallback for missing geopoint
          }
        },
      );

      debugPrint("Fetched ${snapshots.length} documents from Firestore.");

      final bathrooms = snapshots.map((doc) {
        debugPrint("Document ID: ${doc.id}");
        return Bathroom.fromSnapshot(doc);
      }).toList();

      debugPrint("Converted documents to Bathroom objects: ${bathrooms.length}");
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
