import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/Bathroom.dart';
import '../data/models/Review.dart';
import '../controllers/BathroomController.dart';
import './BathroomDetails.dart';
import 'CommentPage.dart';
import '../../../core/constants.dart';

class ReviewPage extends StatelessWidget {
  final Bathroom bathroom;

  const ReviewPage({Key? key, required this.bathroom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review - ${bathroom.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(child: ReviewForm(bathroom: bathroom)),
            const SizedBox(width: 16),
            ActionButtons(bathroom: bathroom),
          ],
        ),
      ),
    );
  }
}

class ReviewForm extends StatefulWidget {
  final Bathroom bathroom;

  const ReviewForm({Key? key, required this.bathroom}) : super(key: key);

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  String cleanliness = Constants.listCleanliness.first;
  String traffic = Constants.listTraffic.first;
  String size = Constants.listSize.first;
  String feedback = "";
  bool accessibility = true;

  void saveReview() {
    final review = Review(
      cleanliness: cleanliness,
      traffic: traffic,
      size: size,
      feedback: feedback,
      accessibility: accessibility,
    );

    final controller = Get.find<BathroomController>();
    controller.addReview(widget.bathroom.id!, review);

    Get.snackbar('Success', 'Review added successfully');
    Get.off(() => BathroomDetails(bathroom: widget.bathroom));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cleanliness', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: cleanliness,
          items: Constants.listCleanliness.map((value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) => setState(() => cleanliness = value!),
        ),
        const SizedBox(height: 16),
        const Text('Traffic', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: traffic,
          items: Constants.listTraffic.map((value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) => setState(() => traffic = value!),
        ),
        const SizedBox(height: 16),
        const Text('Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: size,
          items: Constants.listSize.map((value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) => setState(() => size = value!),
        ),
        const SizedBox(height: 16),
        const Text('Accessibility', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        DropdownButton<bool>(
          value: accessibility,
          items: [
            DropdownMenuItem(value: true, child: const Text('Yes')),
            DropdownMenuItem(value: false, child: const Text('No')),
          ],
          onChanged: (value) => setState(() => accessibility = value!),
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
    );
  }
}

class ActionButtons extends StatelessWidget {
  final Bathroom bathroom;

  const ActionButtons({Key? key, required this.bathroom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Get.to(() => BathroomDetails(bathroom: bathroom));
          },
          child: const Text('Details'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Get.to(() => CommentPage(bathroom: bathroom));
          },
          child: const Text('Comments'),
        ),
      ],
    );
  }
}
