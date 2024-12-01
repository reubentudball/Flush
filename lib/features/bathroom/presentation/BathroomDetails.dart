import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flush/features/bathroom/presentation/EditBathroomPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/BathroomController.dart';
import '../data/models/Bathroom.dart';
import '../data/models/Report.dart';
import '../controllers/ReportController.dart';
import 'package:flush/features/bathroom/presentation/CommentPage.dart';
import 'package:flush/features/bathroom/presentation/HomePage.dart';
import 'package:flush/features/bathroom/presentation/ReviewList.dart';
import 'package:get/get.dart';
import 'QrCodeGenerator.dart';
import 'ReviewPage.dart';
import '../../../core/constants.dart';

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

  List<Widget> buildStarIcons(double score) {
    int fullStars = score.floor();
    double fractionalStar = score - fullStars;
    int emptyStars = 5 - fullStars - (fractionalStar > 0 ? 1 : 0);

    return [
      for (int i = 0; i < fullStars; i++)
        const Icon(Icons.star, color: Colors.amber, size: 20),
      if (fractionalStar > 0)
        const Icon(Icons.star_half, color: Colors.amber, size: 20),
      for (int i = 0; i < emptyStars; i++)
        const Icon(Icons.star_border, color: Colors.amber, size: 20),
    ];
  }



  Color getHealthScoreColor(double healthScore) {
    final int red = ((100 - healthScore) * 2.55).clamp(0, 255).toInt();
    final int green = (healthScore * 2.55).clamp(0, 255).toInt();
    return Color.fromARGB(255, red, green, 0);
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
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom, top: 16),
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
                    .map((category) =>
                    DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                    .toList(),
                onChanged: (value) {
                  selectedCategory = value;
                },
                decoration: const InputDecoration(
                    labelText: "Select a Category"),
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
                      const SnackBar(
                          content: Text('Please select a category.')),
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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditBathroomPage(bathroom: widget.bathroom))
    );
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
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final bathroomController = Get.find<BathroomController>();
        await bathroomController.deleteBathroom(widget.bathroom.id!);
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
              (route) => false,
        );
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Bathroom Details"),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.map),
          tooltip: "Map",
          onPressed: () {
            Get.offAllNamed('/home');
          },
        ),
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
          else if (widget.bathroom.isVerified && widget.bathroom.facilityID != null)
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
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        widget.bathroom.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Directions:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        widget.bathroom.directions,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (widget.bathroom.isVerified && facilityName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.location_city, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              facilityName!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.bathroom.healthScore == 0
                                ? "Health Score: N/A"
                                : "Health Score: ${widget.bathroom.healthScore?.toStringAsFixed(2) ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.bathroom.healthScore != null
                                  ? getHealthScoreColor(widget.bathroom.healthScore!)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline, color: Colors.grey),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Health Score Explanation"),
                                  content: const Text(
                                    "The health score is calculated based on:\n\n"
                                        "- Cleanliness: Weighted at 75%\n"
                                        "- Review Sentiments: Weighted at 25%\n\n"
                                        "The score ranges from 0 (Poor) to 100 (Excellent), combining user feedback and cleanliness ratings to provide an overall score.",
                                    style: TextStyle(fontSize: 16, height: 1.5),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Close"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    buildDetailRowWithStars(
                      "Cleanliness",
                      widget.bathroom.cleanlinessScore,
                      ReviewConstants.cleanlinessDescriptions,
                    ),
                    buildDetailRowWithStars(
                      "Traffic",
                      widget.bathroom.trafficScore,
                      ReviewConstants.trafficDescriptions,
                    ),
                    buildDetailRowWithStars(
                      "Size",
                      widget.bathroom.sizeScore,
                      ReviewConstants.sizeDescriptions,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewPage(bathroom: widget.bathroom),
                              ),
                            );
                          },
                          icon: const Icon(Icons.rate_review),
                          label: const Text('Leave Review'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReviewList(bathroomId: widget.bathroom.id!),
                              ),
                            );
                          },
                          icon: const Icon(Icons.reviews),
                          label: const Text("Reviews"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CommentPage(bathroom: widget.bathroom),
                            ),
                          );
                        },
                        icon: const Icon(Icons.comment),
                        label: const Text("Comments"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Create QR Code at Bottom
            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QrCodeGenerator(bathroomId: widget.bathroom.id!),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code),
                label: const Text('Create QR Code'),
              ),
            ),
          ],
        ),
      ),
    );




  }


  Widget buildDetailRowWithStars(String title, double? score, List<String> descriptions) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            flex: 3,
            child: score != null && score > 0
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: buildStarIcons(score),
                ),
                const SizedBox(height: 4),
                Text(
                  descriptions[(score - 1).clamp(0, descriptions.length - 1).toInt()],
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            )
                : const Text(
              "N/A",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }



}
