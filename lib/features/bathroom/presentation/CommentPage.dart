import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/UserController.dart';
import '../controllers/BathroomController.dart';
import '../data/models/Comment.dart';

class CommentPage extends StatefulWidget {
  final String bathroomId;

  const CommentPage({super.key, required this.bathroomId});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final BathroomController _bathroomController = Get.find<BathroomController>();
  final UserController _userController = Get.find<UserController>();
  late Future<List<Comment>> commentsFuture;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    commentsFuture = _bathroomController.fetchComments(widget.bathroomId);
  }

  void _addComment() async {
    if (_commentController.text.trim().isNotEmpty) {
      final userId = _userController.firebaseUser.value?.uid ?? 'GuestID';
      final newComment = Comment(
        processed: false,
        reviewText: _commentController.text.trim(),
        sentimentScore: 0.0,
        userID: userId,
      );

      await _bathroomController.addComment(widget.bathroomId, newComment);

      setState(() {
        _commentController.clear();
        commentsFuture = _bathroomController.fetchComments(widget.bathroomId);
      });

      Get.snackbar('Success', 'Comment added successfully.',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', 'Comment cannot be empty.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Comments Section
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                        "Failed to load comments: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ));
                }

                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'No comments available.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];

                    return FutureBuilder<String>(
                      future: _userController.getUserName(comment.userID),
                      builder: (context, userSnapshot) {
                        final userName = userSnapshot.data ?? 'Unknown User';
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              comment.reviewText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'By $userName',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Comment Input Section
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
