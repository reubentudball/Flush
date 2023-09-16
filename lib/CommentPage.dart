import 'package:flutter/material.dart';
import '../model/Bathroom.dart';
import '../model/BathroomRepo.dart';
import 'package:get/get.dart';



class CommentPage extends StatefulWidget{

  final Bathroom bathroom;
  const CommentPage({super.key, required this.bathroom });

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {

  late Bathroom bathroom;
  final bathroomRepo = Get.put(BathroomRepository());

  String comment = "";


  @override void initState() {
    super.initState();
    bathroom = widget.bathroom;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Comments"),
        ),
        body: Column(
            children: [ Expanded(child: ListView.builder(
                itemCount: bathroom.comments!.length,
                itemBuilder: (context, index){
                  return Card(
                      child: Row(
                        children: [

                          Padding(padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(bathroom.comments![index]))
                        ],
                      )
                  );
                }),
            ),
              TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.chat_outlined),
                      hintText: "Leave a Comment",
                      labelText: "Comment"
                  ),
                  onChanged: (value){
                    comment = value;
                  }
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                    onPressed: (){
                      bathroom.comments!.add(comment);
                      bathroomRepo.updateBathroom(bathroom);
                      setState((){});

                    },
                    child: const Text("Add Comment")
                ),
              )
            ]
        )
    );
  }
}
