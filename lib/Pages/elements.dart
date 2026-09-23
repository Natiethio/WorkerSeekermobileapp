import 'package:flutter/material.dart';

class Myelements extends StatefulWidget  {

  final String postitle;

  Myelements({required this.postitle, Key? key}) : super(key: key);

  @override
  State<Myelements> createState() => _MyelementsState();

}

class  _MyelementsState extends State<Myelements> {

  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: Container(
          height:350,
          decoration: BoxDecoration(
            color: Color(0xFFF1AB15),
            borderRadius: BorderRadius.circular(12),
          ),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                    widget.postitle, // b/c we use a state
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
             ),
              Padding(
                  padding: EdgeInsets.only(left : 20 , bottom: 12),
                  child: Row(
                   mainAxisAlignment: MainAxisAlignment.start,
                   children: [
                     GestureDetector(
                       onTap: () {
                         setState(() =>
                           isLiked = !isLiked);
                         },
                         child:Column(
                           children: [
                             Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_outlined, color: Colors.black, size: 25, fontWeight: FontWeight.bold,),
                             SizedBox(height: 3),
                             Text("Like", style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700))
                           ],
                         ),
                     ),
                     SizedBox(width: 20),
                     Column(
                       children: [
                         Icon(Icons.mode_comment_outlined, color: Colors.black, size: 25, fontWeight: FontWeight.bold),
                         SizedBox(height: 3),
                         Text("Comment", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),)
                       ],
                     ),
                     SizedBox(width: 25),
                     Column(
                       children: [
                         Icon(Icons.share_outlined, color: Colors.black, size: 25, fontWeight: FontWeight.bold),
                         SizedBox(height: 3),
                         Text("Share", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),)
                       ],
                     )
                   ],
               )
              )
           ]
        )
        )
    );
  }
}