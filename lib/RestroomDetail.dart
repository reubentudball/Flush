import 'package:flush/HomePage.dart';
import 'package:flush/ReviewList.dart';
import 'package:flutter/material.dart';
import 'package:flush/ReviewPage.dart';

import 'model/Bathroom.dart';

const List<String> listHistory = <String> ['Default'];

class RestroomDetail extends StatefulWidget{
  final Bathroom bathroom;

  RestroomDetail({super.key, required this.bathroom});
  @override
  _RestroomDetailState createState() => _RestroomDetailState();
}

class _RestroomDetailState extends State<RestroomDetail> {


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
        title: const Text("Details"),
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

              const Flexible(child:

              Padding(padding: EdgeInsets.all(25),
                  child: Text('Comments: ',style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20,
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
                  child: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,),
                  )
              ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [

              //TODO: Make dropdown list that connects to server, that displays
              //the info depending on selected saved location
              Flexible(child:

              Padding(padding: EdgeInsets.all(25),
                  child: Text('TempDDL',style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 25,
                  ),
                  )
              ),
              ),

              Flexible(child:

              Padding(padding: EdgeInsets.all(25),
                  child: Text('Clean',style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 25,
                  ),
                  )
              ),
              ),

              Flexible(child:

              Padding(padding: EdgeInsets.all(25),
                  child: Text('Low',style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 25,
                  ),
                  )
              ),
              ),

              Flexible(child:

              Padding(padding: EdgeInsets.all(25),
                  child: Text('2-4',style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 25,
                  ),
                  )
              ),
              ),

              Flexible(child:

              Padding(padding: EdgeInsets.all(25),
                  child: Text('Yes',style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 25,
                  ),
                  )
              ),
              ),


              ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewList(bathroomId: bathroom.id!)));}, child: Text("All Reviews"))
            ],

          ),


        ],
        ),



    );
  }

}

class DropdownlistHistory {
}

