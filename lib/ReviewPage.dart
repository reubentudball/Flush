import 'package:flush/HomePage.dart';
import 'package:flutter/material.dart';
import 'Review.dart';
import 'CommentPage.dart';

const List<String> listCleanliness = <String> ['Very Clean','Clean','Messy','Very Messy'];
const List<String> listTraffic = <String> ['High','Moderate','Low','None'];
const List<String> listSize = <String> ['Single-Use','2-4','5-7','More than 7'];
const List<String> listAccessibility = <String> ['Yes','No'];
var cleanliness;
var traffic;
var size;
var feedback;
var accessibilty = true;

var review = Review.create(cleanliness,traffic, size, feedback,accessibilty);



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
          cleanliness = dropdownValue;
          review.cleanliness = cleanliness;
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
          traffic = dropdownValue;
          review.traffic = traffic;
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
          size = dropdownValue;
          review.size = size;
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
          if (dropdownValue == "Yes"){
            accessibilty = true;
          }else if (dropdownValue == "No"){
            accessibilty = false;
          }
          review.accessibility = accessibilty;
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



class ReviewPage extends StatefulWidget{
  @override
    _ReviewPageState createState() => _ReviewPageState();

}
class _ReviewPageState extends State<ReviewPage>{
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
                    Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CommentPage(reviews: review)));
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


                      review.reviewDesc();
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







