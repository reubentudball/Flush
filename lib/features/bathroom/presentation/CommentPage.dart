import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flush/features/bathroom/data/models/Comment.dart';
import 'package:flutter/material.dart';
import '../data/models/Bathroom.dart';
import '../data/repository/BathroomRepo.dart';
import 'package:get/get.dart';
import '../../../core/services/Services.dart';

class CommentPage extends StatefulWidget {
  final Bathroom bathroom;

  const CommentPage({super.key, required this.bathroom});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late Bathroom bathroom;
  final bathroomRepo = Get.put(BathroomRepository());
  late Future<List<Comment>> commentsFuture;

  final TextEditingController _commentController = TextEditingController();

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      try {
        final newComment = Comment(
          processed: false,
          reviewText: _commentController.text,
          sentimentScore: 0.0,
        );

        final newCommentMap = newComment.toMap();

        await FirebaseFirestore.instance
            .collection('Bathroom')
            .doc(bathroom.id!)
            .update({
          'comments': FieldValue.arrayUnion([newCommentMap]),
        });

        setState(() {
          _commentController.clear();
          commentsFuture = fetchComments(bathroom.id!);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully.')),
        );
      } catch (e) {
        log('Error adding comment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add comment. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    bathroom = widget.bathroom;
    if (bathroom.id != null) {
      commentsFuture = fetchComments(bathroom.id!);
    } else {
      commentsFuture = Future.error('Bathroom ID is null');
    }

    log("Bathroom ID: ${bathroom.id!}");
    log("Bathroom Comments: ${bathroom.comments!}");
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final comments = snapshot.data ?? [];

                return comments.isEmpty
                    ? const Center(child: Text('No comments available.'))
                    : ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: Text(comment.reviewText),
                      subtitle:
                      Text('Sentiment Score: ${comment.sentimentScore}'),
                      trailing: Icon(
                        comment.processed ? Icons.check : Icons.error,
                        color: comment.processed ? Colors.green : Colors.red,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                icon: Icon(Icons.chat_outlined),
                hintText: "Leave a Comment",
                labelText: "Comment",
              ),
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
      ),
    );
  }
}
