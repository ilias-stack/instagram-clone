import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:http/http.dart';

import '../../../Models/user_model.dart';
import '../../../Widgets/App UI/post_widget.dart';

class SavedPostsPage extends StatefulWidget {
  const SavedPostsPage({super.key});

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  bool _isLoading = true;

  final _posts = [];

  Future<void> _getSavedPosts() async {
    final url = "http://$serverIpAddress:5000";
    final savedPostsGetRequest =
        await get(Uri.parse('$url/posts/savedPosts?userId=${User.id}'));
    if (savedPostsGetRequest.statusCode == 200) {
      _posts.addAll(jsonDecode(savedPostsGetRequest.body));
    }
  }

  @override
  void initState() {
    super.initState();
    _getSavedPosts().then((value) => setState(() => _isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.bottomBar,
        title: const Text(
          "Saved posts",
          style: AppTextStyles.primaryTextStyle,
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : _posts.isNotEmpty
              ? ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) =>
                      PostWidget(postId: _posts[index]),
                )
              : const Center(
                  child: Text(
                    "You have no saved posts.",
                    style: AppTextStyles.primaryTextStyle,
                  ),
                ),
    );
  }
}
