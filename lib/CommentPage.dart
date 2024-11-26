import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flush/ReviewPage.dart';
import 'package:flush/model/Comment.dart';
import 'package:flutter/material.dart';
import '../model/Bathroom.dart';
import '../model/BathroomRepo.dart';
import 'package:get/get.dart';
import 'Services.dart';


class CommentPage extends StatefulWidget{

  final Bathroom bathroom;

  //final String bathroomId;  // Pass the bathroomId for fetching related comments
  const CommentPage({super.key, required this.bathroom });


  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late Bathroom bathroom;
  final bathroomRepo = Get.put(BathroomRepository());
  late Future<List<Comment>> commentsFuture;

  String commentText = '';

  void _addComment() async {
    if (commentText.isNotEmpty) {
      try {
        // Create a new comment
        final newComment = Comment(
          processed: false,
          reviewText: commentText,
          sentimentScore: 0.0, // Default sentiment score for new comments
        );

        // Convert the new comment to a map
        final newCommentMap = newComment.toMap();

        // Update Firestore by appending the new comment to the `comments` array
        await FirebaseFirestore.instance
            .collection('Bathroom')
            .doc(bathroom.id!)
            .update({
          'comments': FieldValue.arrayUnion([newCommentMap]),
        });

        // Clear the text field
        setState(() {
          commentText = '';
        });

        // Refresh comments
        setState(() {
          commentsFuture = fetchComments(bathroom.id!);
        });
      } catch (e) {
        print('Error adding comment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment cannot be empty.')),
      );
    }
  }

  /*Future<List<Comment>> fetchComments(String bathroomId) async {
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
  }*/

  @override void initState() {
    super.initState();
    bathroom = widget.bathroom;
    // Fetch comments when the page is loaded
    if (bathroom.id != null) {
      commentsFuture = fetchComments(bathroom.id!);
    } else {
      // Handle the error case where bathroom.id is null
      commentsFuture = Future.error('Bathroom ID is null');
    }


    //_getComments(); // Fetch updated comments
    log("bathroom ID: ${bathroom.id!}");
    log("bathroom Comments: ${bathroom.comments!}");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: FutureBuilder<List<Comment>>(
        future: commentsFuture,
        builder: (context, snapshot) {
/*          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No comments available.'));
          }*/

          // If data is available, display the comments
          final comments = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: Text(comment.reviewText),
                      subtitle: Text(
                          'Sentiment Score: ${comment.sentimentScore}'),
                      trailing: Icon(
                        comment.processed ? Icons.check : Icons.error,
                        color: comment.processed ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.chat_outlined),
                    hintText: "Leave a Comment",
                    labelText: "Comment",
                  ),
                  onChanged: (value) {
                    setState(() {
                      commentText = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _addComment,
                  child: const Text("Add Comment"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}