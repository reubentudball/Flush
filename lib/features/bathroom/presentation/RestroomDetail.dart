import 'dart:developer';

import 'package:flush/features/bathroom/presentation/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import './ReviewList.dart';
import '../data/models/Bathroom.dart';
import '../data/repository/BathroomRepo.dart';
import '../data/models/Review.dart';

const List<String> listHistory = <String> ['Default'];

class RestroomDetail extends StatefulWidget{
  final Bathroom bathroom;

  const RestroomDetail({super.key, required this.bathroom});
  @override
  _RestroomDetailState createState() => _RestroomDetailState();
}

class _RestroomDetailState extends State<RestroomDetail> {


  late Bathroom bathroom;
  List<Review> bathroomReviews = [];
  List<String> cleanQual = [];
  List<String> trafficQual = [];
  List<String> sizeQual = [];
  List<String> accessQual = [];
  final bathroomRepo = Get.put(BathroomRepository());

  @override
  void initState(){
    super.initState();
    bathroom = widget.bathroom;
    getReviews();
  }

  void getReviews() async {
    bathroomReviews = (await bathroomRepo.getReviewsFromBathroom(bathroom.id!));
    Future.delayed(const Duration(seconds: 1)).then((value) => setState((){
      for(int i = 0; i < bathroomReviews.length; i++){
        cleanQual.add(bathroomReviews[i].cleanliness);
        trafficQual.add(bathroomReviews[i].traffic);
        sizeQual.add(bathroomReviews[i].size);
        accessQual.add(bathroomReviews[i].accessibility.toString());


      }





    }));
  }

  String findCommonQuality(List<String> qualList){

    var commonQual = {};



    for (var str in qualList) {
      if(!commonQual.containsKey(str)){
        commonQual[str] = 1;
      } else {
        commonQual[str] +=1;
      }
    }
      log("${commonQual.keys.toList()}");

      return commonQual.keys.first;
  }


  @override
  Widget build(BuildContext context) {




    if (bathroomReviews.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Details")),
        body: const Center(
          child: Text("No Reviews Found!"),
        ),
      );
    } else {
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
                    child: Text('Cleanliness', style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25,
                    ),
                    )
                ),
                ),
                const Flexible(child:
                Padding(padding: EdgeInsets.all(25),
                    child: Text('Traffic', style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25,
                    ),
                    )
                ),
                ),
                const Flexible(child:
                Padding(padding: EdgeInsets.all(25),
                    child: Text('Size', style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25,
                    ),
                    )
                ),
                ),
                const Flexible(child:

                Padding(padding: EdgeInsets.all(25),
                    child: Text('Accessibility', style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25,
                    ),
                    )
                ),
                ),

                Padding(padding: const EdgeInsets.fromLTRB(45, 50, 5, 5),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.black
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const HomePage()));
                      },
                      child: const Text('Home', style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15,),
                      )
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //TODO: Make dropdown list that connects to server, that displays
                //the info depending on selected saved location
                Flexible(child:

                Padding(padding: const EdgeInsets.all(25),
                    child: Text(findCommonQuality(cleanQual), style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25,
                    ),
                    )
                ),
                ),

                Flexible(child:

                Padding(padding: const EdgeInsets.all(25),
                    child: Text(findCommonQuality(trafficQual), style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25,
                    ),
                    )
                ),
                ),

                Flexible(child:

                Padding(padding: const EdgeInsets.all(25),
                    child: Text(findCommonQuality(sizeQual), style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25,
                    ),
                    )
                ),
                ),

                Flexible(child:

                Padding(padding: const EdgeInsets.all(25),
                    child: Text(findCommonQuality(accessQual), style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25,
                    ),
                    )
                ),
                ),


                Padding(padding: const EdgeInsets.fromLTRB(45, 45, 5, 5),
                    child: ElevatedButton(style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black
                    ), onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) =>
                          ReviewList(bathroomId: bathroom.id!)));
                    }, child: const Text("All Reviews")))
              ],

            ),


          ],
        ),


      );
    }
  }
}


