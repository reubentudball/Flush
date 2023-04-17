

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'Bathroom.dart';


class BathroomRepository extends GetxController{
  static BathroomRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  createBathroom(Bathroom bathroom){
    _db.collection("Bathroom").add(bathroom.toJson()).whenComplete(() => log("successful add"));
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


}
