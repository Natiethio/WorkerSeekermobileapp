import 'package:flutter/material.dart';

class CustomAppBarScreen  extends StatefulWidget {

  const CustomAppBarScreen ({super.key});

  @override
  State<CustomAppBarScreen > createState() => _CustomAppBarScreenState();
}

class _CustomAppBarScreenState extends State<CustomAppBarScreen> {
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
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade200,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu, color: Colors.black),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Natnael",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => showProfileMenu(context),
                child: CircleAvatar(
                  key: avatarKey,
                  radius: 20,
                  backgroundImage: const NetworkImage(
                    "https://i.pravatar.cc/150?img=10",
                  ),
                ),
              ),
            ),
          ],
        ),
    )
        ;
  }
}