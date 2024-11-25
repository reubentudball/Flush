

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flush/model/Comment.dart';
import 'package:get/get.dart';

import 'Bathroom.dart';
import 'Review.dart';


class BathroomRepository extends GetxController{
  static BathroomRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  createBathroom(Bathroom bathroom){
    bathroom.comments = [];
    _db.collection("Bathroom").add(bathroom.toJson()).whenComplete(() => log("successful add"));
  }

  createReview(String bathroomId, Review review){
    _db.collection("Bathroom").doc(bathroomId).collection("Reviews").add(review.toJson());
  }



  Future<List<Bathroom>> getAllBathrooms() async {
    final snapshot = await _db.collection("Bathroom").get();
    try {

      final bathrooms = snapshot.docs.map((e) => Bathroom.fromSnapshot(e))
          .toList();

      return bathrooms;

    } catch(e){

      log("$e");
      throw e;

    }

  }

  Future<List<Review>> getReviewsFromBathroom(String bathroomId) async{
    final snapshot = await _db.collection("Bathroom").doc(bathroomId).collection("Reviews").get();
    final reviews = snapshot.docs.map((e) => Review.fromSnapshot(e)).toList();
    return reviews;
  }
  Future<List<Comment>> getBathroomComment(String bathroomId) async{
    final snapshot = await _db.collection("Bathroom").doc(bathroomId).get();
    if (snapshot.exists) {
      // Access the comments field in the Bathroom document
      final comments = snapshot.data()?['comments'] ?? [];
      return comments.whereType<Comment>().toList();
    } else {
      // Return an empty list if the document doesn't exist
      return [];
    }
  }

  void updateBathroom(Bathroom bathroom){
    _db.collection("Bathroom").doc(bathroom.id).update(bathroom.toJson());
  }


}
