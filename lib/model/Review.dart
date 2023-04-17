

import 'package:cloud_firestore/cloud_firestore.dart';

class Review{
  String cleanliness = "";
  String traffic = "";
  String size = "";
  String? feedback = "";
  bool accessibility = true;
  bool isFavorite = true;

  Review({required this.cleanliness, required this.traffic, required this.size,this.feedback, required this.accessibility});
  Review.create({required this.cleanliness, required this.traffic, required this.size,this.feedback, required this.accessibility});



  toJson(){
    return {"cleanliness": cleanliness, "traffic":traffic, "size": size, "feedback": feedback, "accessibility":accessibility,"isFavorite":isFavorite};
  }

  factory Review.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> document){

    final data = document.data()!;





    return Review(
        cleanliness: data["cleanliness"],
        traffic: data["traffic"],
        size: data["size"],
        feedback: data["feedback"],
        accessibility: data["accessibility"]

    );
  }


}

/*

   */
