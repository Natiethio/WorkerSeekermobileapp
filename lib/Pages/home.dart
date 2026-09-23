import 'package:flutter/material.dart';
import 'package:firstapp/Pages/elements.dart';
import 'package:firstapp/screens/stories.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => MyHome();
}

class MyHome extends State<Home> {
  final posts = List<String>.generate(10, (i) => 'Post $i');

  final stories = List<String>.generate(15, (i) => 'Story $i');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(

          children: [
            //Stories
            SizedBox(height: 35),
            SizedBox(
                height: 120,
                child: ListView.builder(
                  itemCount: stories.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context,index) {
                    return Mystories(stories: stories[index]);
                  },
                )
            ),
            //Posts
            Expanded(
              child: ListView.builder(
                // Convert the data source into widgets
                //physics: NeverScrollableScrollPhysics(), to make unscrollable
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return Myelements(postitle: posts[index]);
                },
              ),
            ),
          ],
        ),
    );
  }
}
