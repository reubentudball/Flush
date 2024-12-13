import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/BathroomController.dart';
import '../data/models/Bathroom.dart';
import '../../../core/constants.dart';

class EditBathroomPage extends StatefulWidget {
  final Bathroom bathroom;

  const EditBathroomPage({Key? key, required this.bathroom}) : super(key: key);

  @override
  _EditBathroomPageState createState() => _EditBathroomPageState();
}

class _EditBathroomPageState extends State<EditBathroomPage> {
  final _formKey = GlobalKey<FormState>();

  final BathroomController _bathroomController = Get.find<BathroomController>();

  late TextEditingController _titleController;
  late TextEditingController _directionsController;

  String? selectedBathroomType;
  String? selectedAccessType;

  @override
  void initState() {
    super.initState();

    if (!BathroomTypeConstants.bathroomTypes.contains(widget.bathroom.bathroomType)) {
      selectedBathroomType = null;
    } else {
      selectedBathroomType = widget.bathroom.bathroomType;
    }

    if (!AccessTypeConstants.accessTypes.contains(widget.bathroom.accessType)) {
      selectedAccessType = null;
    } else {
      selectedAccessType = widget.bathroom.accessType;
    }

    _titleController = TextEditingController(text: widget.bathroom.title);
    _directionsController = TextEditingController(text: widget.bathroom.directions);
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
        sizeScore: widget.bathroom.sizeScore,
        isVerified: widget.bathroom.isVerified,
        geohash: widget.bathroom.geohash,
        facilityID: widget.bathroom.facilityID,
        ownerID: widget.bathroom.ownerID,
        reviews: widget.bathroom.reviews,
        comments: widget.bathroom.comments,
        accessType: selectedAccessType!,
        bathroomType: selectedBathroomType!,
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
                decoration: const InputDecoration(
                  labelText: "Bathroom Name",
                  hintText: "Enter a meaningful name for the bathroom",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit, color: Colors.blueAccent),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a bathroom name.';
                  }
                  if (value.length < 5) {
                    return 'Bathroom name should be at least 5 characters long.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _directionsController,
                decoration: const InputDecoration(
                  labelText: "Directions (Optional)",
                  hintText: "Provide general directions to locate the bathroom",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions, color: Colors.blueAccent),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Bathroom Type",
                border: OutlineInputBorder(),
              ),
              value: selectedBathroomType,
              items: BathroomTypeConstants.bathroomTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBathroomType = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a bathroom type.';
                }
                return null;
              },
            ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Access Type",
                  border: OutlineInputBorder(),
                ),
                value: selectedAccessType,
                items: AccessTypeConstants.accessTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAccessType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an access type.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
