import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Widgets/App%20UI/delete_confirmation_dialog.dart';
import 'package:frontend/Widgets/App%20UI/profile_image.dart';

class CommentWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final Future<void> Function()? deleteComment;
  const CommentWidget({super.key, required this.data, this.deleteComment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: User.id == data["userId"]
          ? () {
              showDialog(
                  context: context,
                  builder: (_) => DeleteConfirmationDialogue(
                        deletionText: "Delete this comment",
                        onConfirm: deleteComment,
                      ));
            }
          : null,
      contentPadding: const EdgeInsets.only(left: 5, right: 5),
      leading: ProfileImage(
        imageId: data["user"]["profilePictureId"],
        padding: 0,
        size: 20,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data["user"]["username"],
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
          ),
          Text(
            data["text"],
            style: const TextStyle(color: Colors.white, fontSize: 13),
          )
        ],
      ),
    );
  }
}
