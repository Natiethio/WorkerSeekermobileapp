import 'package:flutter/material.dart';
import 'package:firstapp/Components/appbar.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      // appBar: CustomAppBar(),
      body: Center(
        child: Text(
          'Settings',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
