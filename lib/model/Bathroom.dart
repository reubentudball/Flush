
import 'dart:developer';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Review.dart';

class Bathroom{

  final String? id;
  final String title;
  final String directions;
  final LatLng location;
  late List<String>? reviews = [];
  late List<String>? comments = [];


  Bathroom({this.id, required this.title, required this.directions, required this.location, this.reviews, this.comments});

  toJson(){
    return{"title":title, "directions":directions, "location":GeoPoint(location.latitude,location.longitude), "reviews": reviews, "comments":comments};
  }


  factory Bathroom.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> document){

    final data = document.data()!;





    return Bathroom(
      id:document.id,
      title: data["title"],
      directions: data["directions"],
      location: LatLng(data["location"].latitude as double, data["location"].longitude as double),
      reviews: List<String>.from(data["reviews"] as List),
      comments: List<String>.from(data["comments"] as List)
    );
  }

}
