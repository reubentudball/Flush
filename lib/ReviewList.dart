
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'model/BathroomRepo.dart';
import 'model/Review.dart';


class ReviewList extends StatefulWidget{
  final String bathroomId;

  ReviewList({super.key, required this.bathroomId});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList>{

  late String bathroomId;
  final bathroomRepo = Get.put(BathroomRepository());
  List<Review> reviews = [];

  @override
  void initState() {
        super.initState();
        bathroomId = widget.bathroomId;
        _getReviews();
  }

  void _getReviews() async {
    reviews = (await bathroomRepo.getReviewsFromBathroom(bathroomId));
    Future.delayed(const Duration(seconds: 1)).then((value) => setState((){}));
  }


  @override
  Widget build(BuildContext context){
    if(reviews.isEmpty || reviews == null){
      return Scaffold(
        appBar: AppBar(
          title: Text("Reviews"),
        ),
        body: const Center(child: CircularProgressIndicator(),)
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Reviews"),
        ),
        body: ListView.builder(itemCount: reviews.length,
        itemBuilder: (context, index){
          return Card(

            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Cleanliness: ${reviews[index].cleanliness}"),
                    Text("Size: ${reviews[index].size}")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Traffic: ${reviews[index].traffic}"),
                    Text("Accessible?: ${reviews[index].accessibility.toString()}")
                  ],
                ),
              ]
            ),
          );
        },
        ),
      );
    }
  }
}
