import 'dart:developer';
import 'dart:ffi';
import 'NaturalLanguageService.dart';
import 'CommentPage.dart';
import 'HomePage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ReviewList.dart';
import 'model/Bathroom.dart';
import 'model/BathroomRepo.dart';
import 'model/Review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



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
  List<String> bathroomComments = [];
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
    final bathroomDoc = await FirebaseFirestore.instance
        .collection('Bathroom')
        .doc(bathroom.id!)
        .get();
    if (!bathroomDoc.exists) {
      print('Bathroom not found');
      return;
    }
    bathroomReviews = (await bathroomRepo.getReviewsFromBathroom(bathroom.id!));
    //bathroomComments = (await bathroomRepo.getBathroomComment(bathroom.id!));
    // Transform comments and analyze sentiment
    List<dynamic> comments = bathroomDoc.data()?['comments'] ?? [];
    int processedCount = 0;

    for (var comment in comments) {
      if (comment['processed'] == false) {
        double sentimentScore = await sentimentAnalysis.analyzeSentiment(comment['reviewText']);
        commentWeight += sentimentScore; // Sum sentiment scores
        comment['processed'] = true; // Mark comment as processed
        processedCount++;
      }
    }
    if (processedCount > 0) {
      commentWeight = (commentWeight / processedCount) * 100 * commentWeightValue;
    }
    Future.delayed(const Duration(seconds: 1)).then((value) => setState(()
    async {
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
      for (int i = 0; i < bathroomComments.length; i++) {
        commentWeight += await sentimentAnalysis.analyzeSentiment(bathroomComments[i]);
      }
      cleanlinessWeight =
          (((cleanlinessWeight / bathroomReviews.length) / 4.0) * 100) *
              cleanWeightValue; //Turn to percentage (4 is 100%) and apply weighted value
      commentWeight = (commentWeight / bathroomComments.length) * 100 * commentWeightValue;
      healthScore = cleanlinessWeight + commentWeight;

      // Update Firestore with the updated comments and health score
      await FirebaseFirestore.instance.collection('Bathrooms').doc(bathroom.id!).update({
      'comments': comments,
      'healthScore': healthScore,
      });

      log("${healthScore}");

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

