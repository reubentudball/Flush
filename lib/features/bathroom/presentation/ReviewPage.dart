import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/UserController.dart';
import '../data/models/Bathroom.dart';
import '../data/models/Review.dart';
import '../controllers/BathroomController.dart';
import './BathroomDetails.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../core/constants.dart';

class ReviewPage extends StatefulWidget {
  final Bathroom bathroom;

  const ReviewPage({Key? key, required this.bathroom}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int cleanliness = 3;
  int traffic = 3;
  int size = 3;
  String feedback = "";
  List<String> selectedAccessibilityFeatures = [];

  void toggleAccessibilityFeature(String feature) {
    setState(() {
      if (selectedAccessibilityFeatures.contains(feature)) {
        selectedAccessibilityFeatures.remove(feature);
      } else {
        selectedAccessibilityFeatures.add(feature);
      }
    });
  }

  void saveReview() async {
    final userController = Get.find<UserController>();
    final userId = userController.firebaseUser.value?.uid ?? "Anonymous";

    final review = Review(
      cleanliness: cleanliness,
      traffic: traffic,
      size: size,
      feedback: feedback,
      accessibilityFeatures: selectedAccessibilityFeatures,
      userId: userId,
      createdAt: Timestamp.now()
    );

    final controller = Get.find<BathroomController>();
    try {
      await controller.addReview(widget.bathroom.id!, review);
      Get.snackbar('Success', 'Review added successfully');
      Get.off(() => BathroomDetails(bathroom: widget.bathroom));
    } catch (e) {
      Get.snackbar('Error', 'Failed to save review: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review - ${widget.bathroom.title}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cleanliness', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(ReviewConstants.cleanlinessDescriptions[cleanliness - 1]),
            RatingBar.builder(
              initialRating: cleanliness.toDouble(),
              minRating: 1,
              maxRating: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) => setState(() => cleanliness = rating.toInt()),
            ),
            const SizedBox(height: 16),

            const Text('Traffic', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(ReviewConstants.trafficDescriptions[traffic - 1]),
            RatingBar.builder(
              initialRating: traffic.toDouble(),
              minRating: 1,
              maxRating: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) => setState(() => traffic = rating.toInt()),
            ),
            const SizedBox(height: 16),

            const Text('Size (Stalls)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(ReviewConstants.sizeDescriptions[size - 1]),
            RatingBar.builder(
              initialRating: size.toDouble(),
              minRating: 1,
              maxRating: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) => setState(() => size = rating.toInt()),
            ),
            const SizedBox(height: 16),

            const Text('Accessibility Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Column(
              children: AccessibilityConstants.accessibilityFeatures.map((feature) {
                return CheckboxListTile(
                  title: Text(feature),
                  value: selectedAccessibilityFeatures.contains(feature),
                  onChanged: (_) => toggleAccessibilityFeature(feature),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextField(
              decoration: const InputDecoration(labelText: 'Feedback'),
              onChanged: (value) => setState(() => feedback = value),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: saveReview,
              child: const Text('Save Review'),
            ),
          ],
        ),
      ),
    );
  }
}
