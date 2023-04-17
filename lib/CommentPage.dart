import 'package:flutter/material.dart';
import 'model/Review.dart';


class CommentPage extends StatefulWidget{

  final Review reviews;
  CommentPage({Key? key, required this.reviews }) : super(key:key);

  @override
  _CommentPageState createState() => new _CommentPageState(reviews);
}

class _CommentPageState extends State<CommentPage> {
  Review reviews;
  _CommentPageState(this.reviews);
  TextEditingController myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave a Comment"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15),
          child:
          TextField(
            controller: myController,
            maxLines: 6,
            minLines: 1,
            decoration:InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter Comment Here',


            ),
            )
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: ElevatedButton(
                onPressed: () {
                  reviews.feedback = myController.text;


                },
                child: Text('Save')),
          )


        ],
      ),
    );
  }
}
