import 'package:flutter/material.dart';

class Mystories extends StatelessWidget {

  final String stories;

  Mystories({required this.stories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF1AB15),
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: Center(
                child: Text(stories,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
            ),

          ),
          Text(stories,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
