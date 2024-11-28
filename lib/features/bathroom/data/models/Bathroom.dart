import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Bathroom {
  final String? id;
  final String title;
  final String directions;
  final LatLng location;
  final double? healthScore;
  final bool isVerified;
  final double? cleanlinessScore;
  final double? trafficScore;
  final double? accessibilityScore;
  final CollectionReference? reviews;
  final List<dynamic>? comments;

  Bathroom({
    this.id,
    required this.title,
    required this.directions,
    required this.location,
    this.healthScore,
    this.cleanlinessScore,
    this.trafficScore,
    this.accessibilityScore,
    this.isVerified = false,
    this.reviews,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "directions": directions,
      "location": GeoPoint(location.latitude, location.longitude),
      "healthScore": healthScore ?? 0.0,
      "cleanlinessScore": cleanlinessScore ?? 0.0,
      "trafficScore": trafficScore ?? 0.0,
      "accessibilityScore": accessibilityScore ?? 0.0,
      "isVerified": isVerified,
      "reviews": reviews,
      "comments": comments ?? [],
    };
  }

  factory Bathroom.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;

    return Bathroom(
      id: document.id,
      title: data["title"] ?? "Unknown Title",
      directions: data["directions"] ?? "No directions provided",
      location: LatLng(
        (data["location"] as GeoPoint).latitude,
        (data["location"] as GeoPoint).longitude,
      ),
      healthScore: (data["healthScore"] != null)
          ? (data["healthScore"] as num).toDouble()
          : null,
      cleanlinessScore: (data["cleanlinessScore"] != null)
          ? (data["cleanlinessScore"] as num).toDouble()
          : null,
      trafficScore: (data["trafficScore"] != null)
          ? (data["trafficScore"] as num).toDouble()
          : null,
      accessibilityScore: (data["accessibilityScore"] != null)
          ? (data["accessibilityScore"] as num).toDouble()
          : null,
      isVerified: data["isVerified"] ?? false,
      reviews: data["reviews"] != null
          ? FirebaseFirestore.instance.collection(data["reviews"])
          : null,
      comments: data["comments"] as List<dynamic>? ?? [],
    );
  }
}
