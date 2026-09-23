import 'package:flutter/material.dart';

class BackCancelAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onCancel;

  const BackCancelAppBar({
    super.key,
    required this.onBack,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey.shade200,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: onBack,
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
