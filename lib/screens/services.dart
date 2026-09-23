import 'package:flutter/material.dart';
import 'package:firstapp/Pages/serviceshome.dart';
import 'package:firstapp/Pages/categories.dart';
import 'package:firstapp/Pages/bookings.dart';
import 'package:firstapp/Pages/settings.dart';
import 'package:firstapp/Components/appbar.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:firstapp/Components/home_app_bar.dart';
import 'package:firstapp/Components/back_cancel_app_bar.dart';


class WorkersHomePage extends StatefulWidget {
  const WorkersHomePage({super.key});

  @override
  State<WorkersHomePage> createState() => _WorkersHomePageState();
}

class _WorkersHomePageState extends State<WorkersHomePage> {
  int _selectedpage = 0;

  void navigateBottomBar(int index) {
    setState(() {
      _selectedpage = index;
    });
  }

  final List<Widget> _pages = [
    ServicesHome(),
    Workers(),
    Bookings(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    final GlobalKey avatarKey = GlobalKey();

    void showProfileMenu(BuildContext context) {
      final RenderBox renderBox =
          avatarKey.currentContext!.findRenderObject() as RenderBox;

      final Offset offset = renderBox.localToGlobal(Offset.zero);
      final Size size = renderBox.size;

      final RenderBox overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;

      showMenu(
        context: context,
        position: RelativeRect.fromRect(
          Rect.fromLTWH(
            offset.dx - 2, // left align
            offset.dy + size.height + 2, // below avatar
            size.width,
            size.height,
          ),
          Offset.zero & overlay.size,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        items: [
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                Row(
                  children: [
                    // const CircleAvatar(radius: 18, child: Text("NA")),
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150?img=10",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Natnael",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "@natmanpro",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
              ],
            ),
          ),

          // Profile option
          PopupMenuItem(
            child: Row(
              children: const [
                Icon(Icons.person_outline),
                SizedBox(width: 12),
                Text("Profile"),
              ],
            ),
            onTap: () {
              // Navigate to profile
            },
          ),

          // Logout option
          PopupMenuItem(
            child: Row(
              children: const [
                Icon(Icons.logout),
                SizedBox(width: 12),
                Text("Logout"),
              ],
            ),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      );
    }

    void _handleBack() {
      if (_selectedpage > 0) {
        setState(() {
          _selectedpage--;
        });
      }
    }

    void _handleCancel() {
      setState(() {
        _selectedpage = 0; // ServicesHomePage
      });
    }

    PreferredSizeWidget? _buildAppBar(BuildContext context) {
      if (_selectedpage == 0) {
        return HomeAppBar(
          avatarKey: avatarKey,
          onAvatarTap: () => showProfileMenu(context),
        );
      }
      return null;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade200,
      appBar: _buildAppBar(context),
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
              blurRadius: 2,
              offset: Offset(0, -1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: GNav(
          rippleColor: Colors.grey.withOpacity(0.2),
          selectedIndex: _selectedpage,
          onTabChange: navigateBottomBar,
          // 🔹 same logic reused
          haptic: true,
          curve: Curves.easeOutExpo,
          duration: const Duration(milliseconds: 450),
          gap: 8,

          iconSize: 26,
          color: Colors.grey,
          // unselected icon
          activeColor: const Color(0xFF04B461),

          // selected icon + text
          tabBackgroundColor: const Color(0xFF04B461).withOpacity(0.15),
          // light green bg
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

          tabs: const [
            GButton(icon: Icons.home, text: 'Home'),
            GButton(icon: Icons.engineering, text: 'Workers'),
            GButton(icon: Icons.calendar_today_outlined, text: 'Bookings'),
            GButton(icon: Icons.settings, text: 'Settings'),
          ],
        ),
      ),
    );
  }
}
