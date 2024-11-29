import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  int cleanliness = 0;
  int traffic = 0;
  int size = 0;
  String? feedback = "";
  List<String> accessibilityFeatures = [];
  String userId = "";

  Review({
    required this.cleanliness,
    required this.traffic,
    required this.size,
    this.feedback,
    required this.accessibilityFeatures,
    required this.userId
  });

  toJson() {
    return {
      "cleanliness": cleanliness,
      "traffic": traffic,
      "size": size,
      "feedback": feedback,
      "accessibilityFeatures": accessibilityFeatures,
      "userId": userId
    };
  }

  factory Review.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Review(
      cleanliness: data["cleanliness"],
      traffic: data["traffic"],
      size: data["size"],
      feedback: data["feedback"],
      accessibilityFeatures: List<String>.from(data["accessibilityFeatures"] ?? []),
      userId: data["userId"] ?? "",
    );
  }
}
