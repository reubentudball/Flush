import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/BathroomController.dart';
import '../data/models/Bathroom.dart';

class EditBathroomPage extends StatefulWidget {
  final Bathroom bathroom;

  const EditBathroomPage({Key? key, required this.bathroom}) : super(key: key);

  @override
  _EditBathroomPageState createState() => _EditBathroomPageState();
}

class _EditBathroomPageState extends State<EditBathroomPage> {
  final _formKey = GlobalKey<FormState>();

  // Use GetX to access the BathroomController
  final BathroomController _bathroomController = Get.find<BathroomController>();

  late TextEditingController _titleController;
  late TextEditingController _directionsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bathroom.title);
    _directionsController =
        TextEditingController(text: widget.bathroom.directions);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _directionsController.dispose();
    super.dispose();
  }

  void _saveBathroom() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedBathroom = Bathroom(
        id: widget.bathroom.id,
        title: _titleController.text.trim(),
        directions: _directionsController.text.trim(),
        location: widget.bathroom.location,
        healthScore: widget.bathroom.healthScore,
        cleanlinessScore: widget.bathroom.cleanlinessScore,
        trafficScore: widget.bathroom.trafficScore,
        accessibilityScore: widget.bathroom.accessibilityScore,
        isVerified: widget.bathroom.isVerified,
        geohash: widget.bathroom.geohash,
        facilityID: widget.bathroom.facilityID,
        ownerID: widget.bathroom.ownerID,
        reviews: widget.bathroom.reviews,
        comments: widget.bathroom.comments,
      );

      _bathroomController.updateBathroom(updatedBathroom).then((_) {
        Get.offNamedUntil('/bathroom-details', (route) => route.isFirst, arguments: updatedBathroom);
      }).catchError((error) {
        Get.snackbar('Error', 'Failed to update bathroom: $error',
            snackPosition: SnackPosition.BOTTOM);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bathroom'),
        actions: [
          IconButton(
            onPressed: _saveBathroom,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _directionsController,
                decoration: const InputDecoration(labelText: 'Directions'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Directions are required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
