import 'package:flush/features/bathroom/presentation/HomePage.dart';
import '../../auth/controllers/UserController.dart';
import '../controllers/BathroomController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/models/Bathroom.dart';
import '../../../core/constants.dart';

class TagBathroomPage extends StatefulWidget {
  final LatLng location;

  const TagBathroomPage({super.key, required this.location});

  @override
  _TagBathroomPageState createState() => _TagBathroomPageState();
}

class _TagBathroomPageState extends State<TagBathroomPage> {
  final BathroomController _bathroomController = Get.find<BathroomController>();
  final UserController _userController = Get.find<UserController>();

  final _formKey = GlobalKey<FormState>();

  String title = "";
  String directions = "";
  String? selectedBathroomType;
  String? selectedAccessType;

  late LatLng location;

  @override
  void initState() {
    super.initState();
    location = widget.location;
  }

  void _pickHoursOfOperation() {
    // Function to display a dialog for picking hours of operation (optional implementation)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tag Bathroom"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add a New Bathroom",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Bathroom Name Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Bathroom Name",
                  hintText: "Enter a meaningful name for the bathroom",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit, color: Colors.blueAccent),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a bathroom name.';
                  }
                  if (value.length < 5) {
                    return 'Bathroom name should be at least 5 characters long.';
                  }
                  return null;
                },
                onChanged: (value) {
                  title = value;
                },
              ),
              const SizedBox(height: 20),

              // Directions Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Directions (Optional)",
                  hintText: "Provide general directions to locate the bathroom",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions, color: Colors.blueAccent),
                ),
                maxLines: 5,
                onChanged: (value) {
                  directions = value;
                },
              ),
              const SizedBox(height: 20),

              // Bathroom Type Dropdown
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

              // Access Type Dropdown
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

              const SizedBox(height: 30),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final user = _userController.firebaseUser.value;
                      if (user != null) {
                        Bathroom bathroom = Bathroom(
                          title: title,
                          directions: directions,
                          location: location,
                          ownerID: user.uid,
                          bathroomType: selectedBathroomType ?? "Unknown",
                          accessType: selectedAccessType ?? "Unknown",
                        );

                        await _bathroomController.addBathroom(bathroom);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                              (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("You must be logged in to add a bathroom")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
