import 'HomePage.dart';
import '../model/BathroomRepo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'BathroomDetails.dart';
import '../model/Bathroom.dart';

import '../model/Review.dart';



import 'CommentPage.dart';
import '../constants.dart';



var cleanliness = "Very Clean";
var traffic = "High";
var size = "Singe-Use";
var feedback = "";
var accessibilty = true;

Review review = Review(cleanliness: cleanliness,traffic: traffic, size: size, feedback:feedback,accessibility: accessibilty);


class ReviewPage extends StatefulWidget{

  final Bathroom bathroom;

  ReviewPage({super.key, required this.bathroom});


  @override
  _ReviewPageState createState() => _ReviewPageState();

}
class _ReviewPageState extends State<ReviewPage>{


  final bathroomRepo = Get.put(BathroomRepository());
  late Bathroom bathroom;

  @override
  void initState(){
    super.initState();
    bathroom = widget.bathroom;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restroom - A"),
      ),
      body: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Flexible(child:
              Padding(padding: EdgeInsets.all(25),
                  child: Text('Cleanliness',style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 25,
                  ),
                  )
              ),
              ),
              const Flexible(child:
              Padding(padding: EdgeInsets.all(25),
                  child: Text('Traffic',style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 25,
                  ),
                  )
              ),
              ),
              const Flexible(child:
              Padding(padding: EdgeInsets.all(25),
                  child: Text('Size',style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 25,
                  ),
                  )
              ),
              ),
              const Flexible(child:

              Padding(padding: EdgeInsets.all(25),
                  child: Text('Accessibility',style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 25,
                  ),
                  )
              ),
              ),
              Padding(padding: const EdgeInsets.fromLTRB(45, 50, 5, 5),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        onPrimary: Colors.white
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => BathroomDetails(bathroom: bathroom)));
                    },
                    child: const Text('Details', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,),
                    )
                ),
              ),
              Padding(padding: const EdgeInsets.fromLTRB(45, 5, 5, 25),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        onPrimary: Colors.white
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CommentPage(bathroom: bathroom,)));
                    },
                    child: const Text('Comment', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,),
                    )
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              const Flexible(child:
              Padding(padding: EdgeInsets.fromLTRB(45, 10, 5, 25),
                child:DropdownButtonCleanliness(),
              ),
              ),
              const Flexible(child:
              Padding(padding: EdgeInsets.fromLTRB(45, 10, 5, 25),
                child:DropdownButtonTraffic(),
              ),
              ),
              const Flexible(child:
              Padding(padding: EdgeInsets.fromLTRB(45, 10, 5, 25),
                child:DropdownButtonSize(),
              ),
              ),
              const Flexible(child:
              Padding(padding: EdgeInsets.fromLTRB(45, 10, 5, 25),
                child:DropdownButtonAccessibility(),
              ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(45, 35, 5, 25),
                child: ElevatedButton(
                    onPressed: () {
                      bathroomRepo.createReview(bathroom.id!, review);
                      Navigator.push(context, MaterialPageRoute(builder: (_)=>HomePage()));
                    },
                    child: Text('Save', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,),
                    )
                ),
              ),
            ],
          ),
        ],
      ),

    );
  }
}


class DropdownButtonCleanliness extends StatefulWidget {
  const DropdownButtonCleanliness({super.key});

  @override
  State<DropdownButtonCleanliness> createState() => _DropdownButtonCleanlinessState();
}
class _DropdownButtonCleanlinessState extends State<DropdownButtonCleanliness> {
  String dropdownValue = Constants.listCleanliness.first;
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
          cleanliness = dropdownValue;
          review.cleanliness = cleanliness;

        });
      },
      items: Constants.listCleanliness.map<DropdownMenuItem<String>>((String value) {
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
  String dropdownValue = Constants.listTraffic.first;
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
          traffic = dropdownValue;

        });
      },
      items: Constants.listTraffic.map<DropdownMenuItem<String>>((String value) {
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
  String dropdownValue = Constants.listSize.first;
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
          size = dropdownValue;
          review.size = size;

        });
      },
      items: Constants.listSize.map<DropdownMenuItem<String>>((String value) {
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
  String dropdownValue = Constants.listAccessibility.first;
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
          if (dropdownValue == "Yes"){
            accessibilty = true;
          }else if (dropdownValue == "No"){
            accessibilty = false;
          }
          review.accessibility = accessibilty;

        });
      },
      items: Constants.listAccessibility.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}










