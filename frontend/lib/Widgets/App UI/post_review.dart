import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Pages/Secondary%20Pages/Posts%20related/single_post_page.dart';

import '../../constants.dart';
import 'delete_confirmation_dialog.dart';

class PostReview extends StatelessWidget {
  final int length;
  final int id;
  final int? reviewImageId;
  final int? userId;
  final Future<void> Function()? onDelete;
  const PostReview(
      {super.key,
      required this.id,
      this.onDelete,
      required this.length,
      this.userId,
      required this.reviewImageId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: userId == User.id
            ? () => showDialog(
                context: context,
                builder: (_) => DeleteConfirmationDialogue(
                      deletionText: "Delete this post",
                      onConfirm: onDelete,
                    ))
            : null,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SinglePostPage(postId: id))),
        child: Stack(
          children: [
            Center(
              child: Container(
                color: Colors.black12,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    "http://$serverIpAddress:5000/posts/postImage/$reviewImageId",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            length > 1
                ? const Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.collections,
                      color: Colors.white38,
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ));
  }
}
