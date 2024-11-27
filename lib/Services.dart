import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'model/Comment.dart';


Future<List<Comment>> fetchComments(String bathroomId) async {
  try {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Bathroom')
        .doc(bathroomId)
        .get();
    if (!docSnapshot.exists) {
      throw Exception('Bathroom document not found');
    }
    final data = docSnapshot.data()!;
    final commentsData = List<Map<String, dynamic>>.from(
        data['comments'] ?? []);

    // Map each comment data (from array) to a Comment object
    return commentsData.map((commentData) {
      log('CommentList: ${commentData}');
      return Comment.fromJson(
          commentData); // Converting Map to Comment object

    }).toList();
  } catch (e) {
    print('Error fetching comments: $e');
    return []; // Return an empty list if an error occurs
  }
}