import 'package:flutter/material.dart';
import 'package:frontend/Widgets/App%20UI/profile_image.dart';
import 'package:frontend/constants.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Map<String, dynamic> receiver;
  const ChatAppBar({super.key, required this.receiver});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      title: Row(
        children: [
          ProfileImage(imageId: receiver["profilePictureId"], size: 20),
          Text(
            receiver["username"],
            style: AppTextStyles.primaryTextStyle,
          ),
          receiver["isOnline"]
              ? const Text(
                  "  Online",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                )
              : const Text(
                  "  Offline",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
