import 'package:flush/HomePage.dart';
import 'package:flush/model/BathroomRepo.dart';
import 'package:flutter/material.dart';
import 'package:flush/BathroomDetails.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'CommentPage.dart';
import 'model/Bathroom.dart';

const List<String> listCleanliness = <String> ['Very Clean','Clean','Messy','Very Messy'];
const List<String> listTraffic = <String> ['High','Moderate','Low','None'];
const List<String> listSize = <String> ['Single-Use','2-4','5-7','More than 7'];
const List<String> listAccessibility = <String> ['Yes','No'];
class TagBathroomPage extends StatefulWidget{

  final LatLng location;

  TagBathroomPage({super.key, required this.location});

  @override
  _TagBathroomPageState createState() => _TagBathroomPageState();

}
class _TagBathroomPageState extends State<TagBathroomPage>{

  final bathroomRepo = Get.put(BathroomRepository());

  String title = "";
  String directions = "";


  late LatLng location;

  @override
  void initState(){
    super.initState();
    location = widget.location;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          title: Text("Add Bathroom"),
        ),
        body: Form(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: "Provide Meaningful Bathroom Name",
                    labelText: "Bathroom Name"
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 5) {
                    return 'Please enter the bathroom name';
                  }
                },
                onChanged: (value){
                  title = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: "Provide general directions to your bathroom (not required)",
                    labelText: "Directions"
                ),
                // The validator receives the text that the user has entered.
                onChanged: (value){
                  directions = value;
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Bathroom bathroom = Bathroom(title:title, directions: directions, location:location);
                    bathroomRepo.createBathroom(bathroom);
                    Navigator.push(context, MaterialPageRoute(builder: (_)=> HomePage()));
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        )
    );
  }
}



