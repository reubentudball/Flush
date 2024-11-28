import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Bathroom {
  final String? id;
  final String title;
  final String directions;
  final LatLng location;
  final CollectionReference? reviews;
  final List<dynamic>? comments;

  Bathroom({
    this.id,
    required this.title,
    required this.directions,
    required this.location,
    this.reviews,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "directions": directions,
      "location": GeoPoint(location.latitude, location.longitude),
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
      reviews: data["reviews"] != null
          ? FirebaseFirestore.instance.collection(data["reviews"])
          : null,
      comments: data["comments"] as List<dynamic>? ?? [],
    );
  }
}
