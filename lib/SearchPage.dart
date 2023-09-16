import 'package:flush/BathroomDetails.dart';
import 'package:flush/ReviewPage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';


import 'model/Bathroom.dart';
import 'model/BathroomRepo.dart';

const List<String> sortBy = <String>['Nearest', 'Most Clean', 'Most Quiet', 'Most Accessible'];


class SearchPage extends StatefulWidget{

  final Position currentPosition;
  final List<Bathroom> bathrooms;

  SearchPage({super.key, required this.currentPosition, required this.bathrooms});


  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>{

  late Position currentPosition;
  late double distance;
  final bathroomRepo = Get.put(BathroomRepository());
  late List<Bathroom> bathrooms;

  @override
  void initState() {
    currentPosition = widget.currentPosition;
    bathrooms = widget.bathrooms;
  }


  ScrollController sc = ScrollController();


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Bathroom"),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [Row(
          children: const <Widget>[
            Expanded(
              child: Padding(
              padding: EdgeInsets.only(left: 20),


            child :TextField(
              decoration: InputDecoration(
                hintText: 'Search for location',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
            ),
            SortingDropDown(),

    ],


      ),
          ListView.builder(itemCount: bathrooms.length,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              itemBuilder: (context, index){
                return Card(

                    child: Column(
                      children: [Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(style: const TextStyle(fontWeight: FontWeight.bold), bathrooms[index].title)
                      ],
                    ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: [const Text(style: TextStyle(fontWeight: FontWeight.bold),"Directions: "),
                          Flexible(
                              child: Container(padding:  const EdgeInsets.only(right: 13.0),
                              child:Text(bathrooms[index].directions)))
                          ,

                        ],),
                        Row(mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(style: ElevatedButton.styleFrom(
                            ), onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                  BathroomDetails(bathroom: bathrooms[index])
                              ));}, child: Text("See Details"))
                          ],
                        )
                  ]
                    ),
                );

              }
          )
    ]
      )
    );
  }
}

class SortingDropDown extends StatefulWidget{
  const SortingDropDown({super.key});

  @override
  _SortingDropDownState createState() => _SortingDropDownState();
}

class _SortingDropDownState extends State<SortingDropDown>{
  String defaultValue = sortBy.first;

  @override
  Widget build(BuildContext context){
    return DropdownButton<String>(
      value: defaultValue,
      icon: const Icon(Icons.sort),

      onChanged: (String? value) {
        setState(() {
          defaultValue = value!;
        });
      },
      items: sortBy.map<DropdownMenuItem<String>>((String value){
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value)
        );
      }).toList(),
    );
  }
}
