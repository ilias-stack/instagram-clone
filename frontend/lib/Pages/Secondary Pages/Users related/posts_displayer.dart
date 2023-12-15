import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../Widgets/App UI/post_review.dart';
import '../../../constants.dart';

import 'package:http/http.dart' as http;

class PostsDisplayer extends StatefulWidget {
  final int userId;
  final void Function(int) postsCountUpdater;
  const PostsDisplayer(
      {super.key, required this.userId, required this.postsCountUpdater});

  @override
  State<PostsDisplayer> createState() => _PostsDisplayerState();
}

class _PostsDisplayerState extends State<PostsDisplayer> {
  late bool _isLoadingData;
  Map<String, dynamic>? _postsReview;
  final url = "http://$serverIpAddress:5000";

  Future<void> _loadData() async {
    final getPostsRequest = await http
        .get(Uri.parse('$url/posts/userPostsReview/${widget.userId}'));
    if (getPostsRequest.statusCode == 200) {
      _postsReview = jsonDecode(getPostsRequest.body);
      widget.postsCountUpdater(_postsReview!["L"]);
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoadingData = true;

    _loadData().then((value) => setState(() {
          _isLoadingData = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoadingData
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : _postsReview!["L"] == 0
              ? const Text(
                  "This user has no posts.",
                  style: AppTextStyles.primaryTextStyle,
                )
              : GridView.builder(
                  itemBuilder: (context, index) => PostReview(
                      onDelete: () async {
                        final deletePostRequest = await http.get(Uri.parse(
                            '$url/posts/delete/${_postsReview!["P"][index]["id"]}'));
                        if (deletePostRequest.statusCode == 200) {
                          setState(() {
                            _postsReview!["L"]--;
                            _postsReview!["P"].removeAt(index);
                          });
                        }
                      },
                      userId: widget.userId,
                      id: _postsReview!["P"][index]["id"] as int,
                      length: _postsReview!["P"][index]["length"] as int,
                      reviewImageId:
                          _postsReview!["P"][index]["reviewImage"] as int?),
                  itemCount: _postsReview!["L"],
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2),
                ),
    );
  }
}
