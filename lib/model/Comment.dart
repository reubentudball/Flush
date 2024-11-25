

import 'package:cloud_firestore/cloud_firestore.dart';

class Comment{
  bool processed = false;
  String reviewText = "";
  double sentimentScore = 0.0;

  Comment({required this.processed, required this.reviewText, required this.sentimentScore});
  Comment.create({required this.processed, required this.reviewText, required this.sentimentScore});



  toJson(){
    return {"processed": processed, "reviewText":reviewText, "sentimentScore": sentimentScore};
  }

  factory Comment.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> document){

    final data = document.data()!;





    return Comment(
        processed: data["processed"],
        reviewText: data["reviewText"],
        sentimentScore: data["sentimentScore"]

    );
  }


}

/*

   */
