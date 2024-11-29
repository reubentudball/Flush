import 'package:flush/features/bathroom/presentation/HomePage.dart';
import '../../auth/controllers/UserController.dart';
import '../controllers/BathroomController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import '../data/models/Bathroom.dart';

const List<String> listCleanliness = <String> ['Very Clean','Clean','Messy','Very Messy'];
const List<String> listTraffic = <String> ['High','Moderate','Low','None'];
const List<String> listSize = <String> ['Single-Use','2-4','5-7','More than 7'];
const List<String> listAccessibility = <String> ['Yes','No'];
class TagBathroomPage extends StatefulWidget {
  final LatLng location;

  const TagBathroomPage({super.key, required this.location});

  @override
  _TagBathroomPageState createState() => _TagBathroomPageState();
}

class _TagBathroomPageState extends State<TagBathroomPage> {
  final BathroomController _bathroomController = Get.find<BathroomController>();
  final UserController _userController = Get.find<UserController>();

  String title = "";
  String directions = "";

  late LatLng location;

  @override
  void initState() {
    super.initState();
    location = widget.location;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Bathroom"),
      ),
      body: Form(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: "Provide Meaningful Bathroom Name",
                labelText: "Bathroom Name",
              ),
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 5) {
                  return 'Please enter the bathroom name';
                }
                return null;
              },
              onChanged: (value) {
                title = value;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: "Provide general directions to your bathroom (not required)",
                labelText: "Directions",
              ),
              onChanged: (value) {
                directions = value;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  final user = _userController.firebaseUser.value;
                  if (user != null) {
                    Bathroom bathroom = Bathroom(
                      title: title,
                      directions: directions,
                      location: location,
                      ownerID: user.uid,
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
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





