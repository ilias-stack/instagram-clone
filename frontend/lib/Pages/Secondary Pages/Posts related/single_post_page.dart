import 'package:flutter/material.dart';
import 'package:frontend/Widgets/App%20UI/post_widget.dart';
import 'package:frontend/constants.dart';

class SinglePostPage extends StatelessWidget {
  final int postId;
  const SinglePostPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.bottomBar,
        elevation: 0,
        title: const Text(
          "Post",
          style: AppTextStyles.primaryTextStyle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: PostWidget(
          postId: postId,
        ),
      ),
    );
  }
}
