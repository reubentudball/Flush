import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/repository/BathroomRepo.dart';
import '../data/models/Review.dart';

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
                  Text(
                    "Review ${index + 1}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cleanliness:",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(review.cleanliness),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Size:",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(review.size),
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
                            Text(
                              "Traffic:",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(review.traffic),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Accessible?",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(review.accessibility ? "Yes" : "No"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (review.feedback!.isNotEmpty)
                    const SizedBox(height: 8),
                  if (review.feedback!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Feedback:",
                          style:
                          TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(review.feedback!),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
