import 'dart:developer';

import 'CommentPage.dart';
import 'HomePage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ReviewList.dart';
import 'model/Bathroom.dart';
import 'model/BathroomRepo.dart';
import 'model/Review.dart';




class BathroomDetails extends StatefulWidget{

  final Bathroom bathroom;

  BathroomDetails({super.key, required this.bathroom});

  @override
  _BathroomDetailState createState() => _BathroomDetailState();
}

class _BathroomDetailState extends State<BathroomDetails> {

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

    var commonQual = Map();



    qualList.forEach((str){
      if(!commonQual.containsKey(str)){
        commonQual[str] = 1;
      } else {
        commonQual[str] +=1;
      }
    });
    log("${commonQual.keys.toList()}");

    return commonQual.keys.first;
  }


  String accessConv(String bool){
    if (bool == "true"){
      return "Yes";
    } else {
      return "No";
    }
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
          body:Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Flexible(child:
                        Padding(padding: EdgeInsets.all(25),
                            child: Text('Cleanliness', style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25,
                            ),
                            )
                        ),
                        ),
                        Flexible(child:
                        Padding(padding: EdgeInsets.all(25),
                            child: Text('Traffic', style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25,
                            ),
                            )
                        ),
                        ),
                        Flexible(child:
                        Padding(padding: EdgeInsets.all(25),
                            child: Text('Size', style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25,
                            ),
                            )
                        ),
                        ),
                        Flexible(child:

                        Padding(padding: EdgeInsets.all(25),
                            child: Text('Accessibility', style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25,
                            ),
                            )
                        ),
                        ),


                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

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
                            child: Text(accessConv(findCommonQuality(accessQual)), style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25,
                            ),
                            )
                        ),
                        ),


                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                            onPrimary: Colors.white
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => HomePage()));
                        },
                        child: const Text('Home', style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15,),
                        )
                    ),



                    ElevatedButton(style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        onPrimary: Colors.white
                    ), onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) =>

                          ReviewList(bathroomId: bathroom.id!)));
                    }, child: const Text("All Reviews")),

                    ElevatedButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CommentPage(bathroom: bathroom)));
                        },
                        child: const Text("See Comments")
                    )
                  ],
                )
              ]
          )
      );
    }
  }
}

