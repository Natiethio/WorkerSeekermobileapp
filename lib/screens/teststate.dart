import 'package:flutter/material.dart';

class MyCounter extends StatefulWidget{
  @override
  State<MyCounter>createState()=>_MyCounterState();
}

class _MyCounterState extends State<MyCounter>{
  int counter = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children : [
           Text('Count : $counter',
           style : TextStyle(
             fontWeight: FontWeight.bold,
             color: Colors.blue
           )),
        Container(
          child : ElevatedButton(
            onPressed: (){
              setState(() {
                counter++;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF174E8E),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Count',
            style: TextStyle(
                color:Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
            )),
          )
        )
      ],
    );
  }
  }
