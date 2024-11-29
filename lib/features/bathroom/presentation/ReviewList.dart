import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/repository/BathroomRepo.dart';
import '../data/models/Review.dart';
import '../../../core/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting date

class ReviewList extends StatefulWidget {
  final String bathroomId;

  const ReviewList({Key? key, required this.bathroomId}) : super(key: key);

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  late String bathroomId;
  final bathroomRepo = Get.put(BathroomRepository());
  List<Review> reviews = [];
  bool isLoading = true;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Map<String, String> userCache = {};

  final Map<String, IconData> accessibilityIcons = {
    "Wheelchair Accessible": Icons.wheelchair_pickup,
    "Braille Signage": Icons.touch_app,
    "Elevator Access": Icons.elevator,
    "Automatic Doors": Icons.sensor_door,
    "Accessible Parking": Icons.local_parking,
    "Grab Bars": Icons.handyman,
    "Low Counters": Icons.countertops,
    "Wide Doorways": Icons.door_sliding,
  };

  @override
  void initState() {
    super.initState();
    bathroomId = widget.bathroomId;
    _getReviews();
  }

  void _getReviews() async {
    reviews = await bathroomRepo.getReviewsFromBathroom(bathroomId);
    setState(() {
      isLoading = false;
    });
  }

  Future<String> _getUserName(String userId) async {
    if (userCache.containsKey(userId)) {
      return userCache[userId]!;
    }

    try {
      final doc = await firestore.collection("User").doc(userId).get();
      final name = doc.data()?["username"] ?? "Unknown User";

      userCache[userId] = name;
      return name;
    } catch (e) {
      return "Unknown User";
    }
  }

  String _getDescription(List<String> descriptions, int rating) {
    if (rating < 1 || rating > 5) {
      return "Unknown";
    }
    return descriptions[rating - 1];
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews"),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : reviews.isEmpty
          ? const Center(
        child: Text(
          "No reviews available.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return FutureBuilder<String>(
            future: _getUserName(review.userId),
            builder: (context, snapshot) {
              final userName = snapshot.data ?? "Loading...";
              final createdAt =
              review.createdAt != null ? _formatTimestamp(review.createdAt!) : "Unknown Time";

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Cleanliness:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _getDescription(
                                      ReviewConstants
                                          .cleanlinessDescriptions,
                                      review.cleanliness),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Size:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _getDescription(
                                      ReviewConstants.sizeDescriptions,
                                      review.size),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Traffic:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _getDescription(
                                      ReviewConstants
                                          .trafficDescriptions,
                                      review.traffic),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Accessibility Features:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      if (review.accessibilityFeatures.isNotEmpty)
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: review.accessibilityFeatures.map(
                                (feature) {
                              final icon = accessibilityIcons[feature] ??
                                  Icons.help_outline;
                              return Row(
                                children: [
                                  Icon(icon, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(feature),
                                ],
                              );
                            },
                          ).toList(),
                        )
                      else
                        const Text(
                            "No accessibility features listed."),
                      if (review.feedback!.isNotEmpty)
                        const SizedBox(height: 8),
                      if (review.feedback!.isNotEmpty)
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Feedback:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(review.feedback!),
                          ],
                        ),
                      const Divider(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Created by: $userName",
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey),
                            ),
                            Text(
                              "Reviewed at: $createdAt",
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
