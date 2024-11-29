import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/Bathroom.dart';
import '../data/models/Report.dart';
import '../controllers/ReportController.dart';
import 'package:flush/features/bathroom/presentation/CommentPage.dart';
import 'package:flush/features/bathroom/presentation/HomePage.dart';
import 'package:flush/features/bathroom/presentation/ReviewList.dart';
import 'package:get/get.dart';

import 'ReviewPage.dart';

class BathroomDetails extends StatefulWidget {
  final Bathroom bathroom;

  const BathroomDetails({super.key, required this.bathroom});

  @override
  _BathroomDetailsState createState() => _BathroomDetailsState();
}

class _BathroomDetailsState extends State<BathroomDetails> {
  final ReportController _reportController = Get.find<ReportController>();
  String? facilityName;

  @override
  void initState() {
    super.initState();
    if (widget.bathroom.isVerified && widget.bathroom.facilityID != null) {
      _fetchFacilityName();
    }
  }

  Future<void> _fetchFacilityName() async {
    try {
      final facilityRef = FirebaseFirestore.instance
          .collection('Facility')
          .doc(widget.bathroom.facilityID);

      final facilityDoc = await facilityRef.get();
      if (facilityDoc.exists) {
        setState(() {
          facilityName = facilityDoc.data()?['name'] ?? 'Unknown Facility';
        });
      }
    } catch (e) {
      debugPrint("Error fetching facility name: $e");
    }
  }

  void _reportIssue() {
    final TextEditingController descriptionController = TextEditingController();
    String? selectedCategory = _reportController.reportCategories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Report a Problem",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: _reportController.reportCategories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  selectedCategory = value;
                },
                decoration: const InputDecoration(labelText: "Select a Category"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Additional Details (Optional)",
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (selectedCategory != null) {
                    _submitReport(
                        selectedCategory!, descriptionController.text.trim());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a category.')),
                    );
                  }
                },
                child: const Text("Submit Report"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitReport(String category, String description) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'Anonymous';
    final report = Report(
      category: category,
      description: description,
      userId: userId,
      timestamp: Timestamp.now(),
    );

    _reportController.submitReport(widget.bathroom.id!, report);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report submitted successfully.")),
    );
  }

  bool get isOwner {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return userId != null && userId == widget.bathroom.ownerID;
  }

  void _editBathroom() {
    Navigator.pushNamed(context, '/edit', arguments: widget.bathroom);
  }

  void _deleteBathroom() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text(
            "Are you sure you want to delete this bathroom? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel deletion
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm deletion
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('Bathroom')
            .doc(widget.bathroom.id)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bathroom deleted successfully.")),
        );
        Navigator.pop(context); // Navigate back after deletion
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete bathroom: $e")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bathroom Details"),
        actions: [
          if (isOwner)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Edit') {
                  _editBathroom();
                } else if (value == 'Delete') {
                  _deleteBathroom();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                const PopupMenuItem(value: 'Delete', child: Text('Delete')),
              ],
            )
          else if (widget.bathroom.isVerified &&
              widget.bathroom.facilityID != null)
            IconButton(
              icon: const Icon(Icons.report_problem),
              tooltip: "Report a Problem",
              onPressed: _reportIssue,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Bathroom Information
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Title", widget.bathroom.title),
                    _buildDetailRow("Directions", widget.bathroom.directions),
                    if (widget.bathroom.isVerified && facilityName != null)
                      _buildDetailRow("Facility", facilityName!),
                  ],
                ),
              ),
            ),

            // Precomputed Scores from Firestore
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Health Score: ${widget.bathroom.healthScore?.toStringAsFixed(2) ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      "Cleanliness Score",
                      widget.bathroom.cleanlinessScore?.toStringAsFixed(2) ??
                          "N/A",
                    ),
                    _buildDetailRow(
                      "Traffic Score",
                      widget.bathroom.trafficScore?.toStringAsFixed(2) ?? "N/A",
                    ),
                    _buildDetailRow(
                      "Accessibility Score",
                      widget.bathroom.accessibilityScore?.toStringAsFixed(2) ??
                          "N/A",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  },
                  child: const Text('Home'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewList(bathroomId: widget.bathroom.id!),
                      ),
                    );
                  },
                  child: const Text("All Reviews"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentPage(bathroom: widget.bathroom),
                      ),
                    );
                  },
                  child: const Text("See Comments"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ReviewPage(bathroom: widget.bathroom),
                  ),
                );
              },
              child: const Text('Leave a Review'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
