import 'dart:developer';
import 'dart:ffi';
//import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'NaturalLanguageService.dart';
import 'CommentPage.dart';
import 'HomePage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ReviewList.dart';
import 'model/Bathroom.dart';
import 'model/BathroomRepo.dart';
import 'model/Review.dart';
import 'model/Comment.dart';
import 'Services.dart';



class BathroomDetails extends StatefulWidget{

  final Bathroom bathroom;

  BathroomDetails({super.key, required this.bathroom});

  @override
  _BathroomDetailState createState() => _BathroomDetailState();
}

class _BathroomDetailState extends State<BathroomDetails> {

  late Bathroom bathroom;
  final NaturalLanguageService sentimentAnalysis = NaturalLanguageService();
  List<Review> bathroomReviews = [];
  List<Comment> bathroomComments = [];
  List<String> cleanQual = [];
  List<String> trafficQual = [];
  List<String> sizeQual = [];
  List<String> accessQual = [];
  List<String> commentQual = [];
  final bathroomRepo = Get.put(BathroomRepository());
  var cleanlinessWeight = 0.0;
  var commentWeight = 0.0;
  var healthScore = 0.0;


  @override
  void initState(){
    super.initState();
    bathroom = widget.bathroom;

    getReviews();
    getHealthScore();
    log("bathroom ID: ${bathroom.id!}");
    log("bathroom Comments: ${bathroom.comments!}");
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
  void getHealthScore() async{
    //cleanlinessWeight = 2.0;
    var cleanWeightValue = 0.75; //How much cleanliness is weighted
    var commentWeightValue = 0.25;

    bathroomReviews = (await bathroomRepo.getReviewsFromBathroom(bathroom.id!));
    bathroomComments = await fetchComments(bathroom.id!);
    log('Does this work: ${bathroomComments.length}');
    // Transform comments and analyze sentiment
    for (int i = 0; i < bathroomReviews.length; i++) {
      cleanQual.add(bathroomReviews[i].cleanliness);
      if (cleanQual[i] == 'Very Clean') {
        cleanlinessWeight += 4.0;
      } else if (cleanQual[i] == 'Clean') {
        cleanlinessWeight += 3.0;
      } else if (cleanQual[i] == 'Messy') {
        cleanlinessWeight += 2.0;
      } else if (cleanQual[i] == 'Very Messy') {
        cleanlinessWeight += 1.0;
      }
    }
    int processedCount = 0;
    for (var comment in bathroomComments) {
      if (comment.processed == false) {
        double sentimentScore = await sentimentAnalysis.analyzeSentiment(comment.reviewText);
        commentWeight += sentimentScore; // Sum sentiment scores
        comment.processed = true; // Mark comment as processed
        processedCount++;
        log('Sentiment: $sentimentScore');
        log('Count: $processedCount');
      }
    }
      //If comment has not been analyzed then preform sentiment analysis on it
      cleanlinessWeight =
          (((cleanlinessWeight / bathroomReviews.length) / 4.0) * 100) *
              cleanWeightValue; //Turn to percentage (4 is 100%) and apply weighted value

      //if any sentment analysis was preformed during a calc then recalculate the weighted score
      if(processedCount > 0){
        commentWeight = (commentWeight / processedCount) * 100 * commentWeightValue;
      }

      healthScore = cleanlinessWeight + commentWeight;
 // Update Firestore with the updated comments and health score
       await FirebaseFirestore.instance.collection('Bathroom').doc(bathroom.id!).update({
         'comments': bathroomComments,
         'healthScore': healthScore,
       });
    log("${healthScore}");





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

