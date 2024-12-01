import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/bathroom/data/models/Comment.dart';


Future<List<Comment>> fetchComments(String bathroomId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('Bathroom')
        .doc(bathroomId)
        .get();

    final data = doc.data();
    if (data == null || !data.containsKey('comments')) return [];

    final comments = (data['comments'] as List<dynamic>).map((commentData) {
      return Comment.fromJson(commentData);
    }).toList();

    return comments;
  } catch (e) {
    log('Error fetching comments: $e');
    return [];
  }
}
