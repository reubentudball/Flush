import 'package:flush/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flush/RestroomDetail.dart';

import 'CommentPage.dart';

const List<String> listCleanliness = <String> ['Very Clean','Clean','Messy','Very Messy'];
const List<String> listTraffic = <String> ['High','Moderate','Low','None'];
const List<String> listSize = <String> ['Single-Use','2-4','5-7','More than 7'];
const List<String> listAccessibility = <String> ['Yes','No'];
class TagBathroomPage extends StatefulWidget{
  @override
  _TagBathroomPageState createState() => _TagBathroomPageState();

}
class _TagBathroomPageState extends State<TagBathroomPage>{
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter the bathroom name';
                  }
                },
                onChanged: (value){

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

                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {

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




class DropdownButtonCleanliness extends StatefulWidget {
  const DropdownButtonCleanliness({super.key});

  @override
  State<DropdownButtonCleanliness> createState() => _DropdownButtonCleanlinessState();
}
class _DropdownButtonCleanlinessState extends State<DropdownButtonCleanliness> {
  String dropdownValue = listCleanliness.first;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: listCleanliness.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}




class DropdownButtonTraffic extends StatefulWidget {
  const DropdownButtonTraffic({super.key});
  @override
  State<DropdownButtonTraffic> createState() => _DropdownButtonTrafficState();
}
class _DropdownButtonTrafficState extends State<DropdownButtonTraffic> {
  String dropdownValue = listTraffic.first;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: listTraffic.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}




class DropdownButtonSize extends StatefulWidget {
  const DropdownButtonSize({super.key});
  @override
  State<DropdownButtonSize> createState() => _DropdownButtonSizeState();
}
class _DropdownButtonSizeState extends State<DropdownButtonSize> {
  String dropdownValue = listSize.first;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: listSize.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}




class DropdownButtonAccessibility extends StatefulWidget {
  const DropdownButtonAccessibility({super.key});
  @override
  State<DropdownButtonAccessibility> createState() => _DropdownButtonAccessibilityState();
}
class _DropdownButtonAccessibilityState extends State<DropdownButtonAccessibility> {
  String dropdownValue = listAccessibility.first;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: listAccessibility.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}


