import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Widgets/App%20UI/post_widget.dart';
import 'package:http/http.dart';

import '../../constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  final _posts = [];
  int _countBlock = 10;
  Future<void> _getPosts() async {
    final url = "http://$serverIpAddress:5000";
    final postsGetRequest =
        await get(Uri.parse('$url/posts/suggestfor?userId=${User.id}'));
    if (postsGetRequest.statusCode == 200) {
      _posts.addAll(jsonDecode(postsGetRequest.body));
    }
  }

  @override
  void initState() {
    super.initState();
    _getPosts().then((value) => setState(() => _isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: Colors.black54,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : _posts.isNotEmpty
              ? ListView.builder(
                  itemCount:
                      _posts.length > _countBlock ? _countBlock : _posts.length,
                  itemBuilder: (context, index) =>
                      PostWidget(postId: _posts[index]),
                )
              : const Center(
                  child: Text(
                    "You have no posts, try following more people.",
                    style: AppTextStyles.primaryTextStyle,
                  ),
                ),
      onRefresh: () async {
        setState(() {
          _isLoading = true;
          _posts.clear();
          _countBlock += 5;
        });
        _getPosts().then((value) => setState(() => _isLoading = false));
      },
    );
  }
}
