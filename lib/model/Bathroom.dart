
import 'dart:developer';

import 'package:flush/model/Comment.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Review.dart';

class Bathroom{

  final String? id;
  final String title;
  final String directions;
  final LatLng location;
  late CollectionReference? reviews;
  late List<dynamic>? comments = [];


  Bathroom({this.id, required this.title, required this.directions, required this.location, this.reviews, this.comments});

  toJson(){
    return{"title":title, "directions":directions, "location":GeoPoint(location.latitude,location.longitude),
      "reviews": reviews, "comments":comments?.map((comment) => comment.toMap()).toList() ?? [],
    };
  }


  factory Bathroom.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> document){

    final data = document.data()!;

    return Bathroom(
      id:document.id,
      title: data["title"],
      directions: data["directions"],
      location: LatLng(data["location"].latitude as double, data["location"].longitude as double),
      reviews: data["Reviews"],
      comments: (data["comments"] as List<dynamic>).toList()
    );
  }

}
