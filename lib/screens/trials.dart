import 'package:flutter/material.dart';
import 'package:firstapp/Pages/home.dart';
import 'package:firstapp/Pages/posts.dart';
import 'package:firstapp/Pages/profiles.dart';
import 'package:firstapp/Pages/settings.dart';

class Trials extends StatefulWidget {
  const Trials({super.key});

  @override
  State<Trials> createState() => _MyWidgetTrails();
}

class _MyWidgetTrails extends State<Trials> {

  int _selectedpage = 0;

  void navigateBottomBar(int index) {
    setState(() {
      _selectedpage = index;
    });
  }

  final List<Widget> _pages = [
    Home(),
    Posts(),
    Profiles(),
    Settings(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedpage],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300, // very thin light gray line
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // very light shadow
              blurRadius: 4,
              offset: Offset(0, -1), // shadow goes upward
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedpage,
          onTap: navigateBottomBar,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // important
          elevation: 0, // remove default elevation
          selectedItemColor: Color(0xFFF1AB15),
          unselectedItemColor: Colors.grey,
          iconSize: 30,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Posts'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
