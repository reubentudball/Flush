import 'package:flutter/material.dart';
class CommentPage extends StatefulWidget{
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave a Comment"),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(15),
          child:
          TextField(
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
                onPressed: () {},
                child: Text('Save')),
          )


        ],
      ),
    );
  }
}