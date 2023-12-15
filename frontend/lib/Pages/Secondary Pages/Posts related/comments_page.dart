import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Widgets/App%20UI/comment.dart';
import 'package:frontend/constants.dart';
import 'package:http/http.dart' as http;

import '../../../Widgets/App UI/send_message_button.dart';

class CommentsPage extends StatefulWidget {
  final int postId;
  const CommentsPage({super.key, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late bool _isLoading = true;
  final url = "http://$serverIpAddress:5000";

  List comments = [];

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });
    final getCommentsRequest =
        await http.get(Uri.parse('$url/posts/${widget.postId}/getAllComments'));
    if (getCommentsRequest.statusCode == 200) {
      comments = jsonDecode(getCommentsRequest.body);
    }
  }

  Future<void> _postComment() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      final postCommentRequest = await http.post(
        Uri.parse('$url/posts/${widget.postId}/postComment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            <String, dynamic>{"userId": User.id, "text": _controller.text}),
      );
      if (postCommentRequest.statusCode == 200) {
        _controller.clear();
        setState(() {
          comments.insert(0, jsonDecode(postCommentRequest.body));
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadComments().then((value) => setState(() {
          _isLoading = false;
        }));
  }

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.bottomBar,
        title: const Text(
          'Comments',
          style: AppTextStyles.primaryTextStyle,
        ),
      ),
      body: RefreshIndicator(
          backgroundColor: AppColors.bottomBar,
          child: Container(
              color: AppColors.backgroundColor,
              child: Stack(
                children: [
                  !_isLoading
                      ? ListView.builder(
                          itemCount: comments.length + 1,
                          itemBuilder: (BuildContext context, int index) =>
                              index < comments.length
                                  ? CommentWidget(
                                      deleteComment: () async {
                                        final deleteComment = await http.get(
                                            Uri.parse(
                                                '$url/posts/${comments[index]["id"]}/deleteComment'));
                                        if (deleteComment.statusCode == 200) {
                                          setState(() {
                                            comments.removeAt(index);
                                          });
                                        }
                                      },
                                      data: comments[index],
                                    )
                                  : const SizedBox(
                                      height: 80,
                                    ),
                        )
                      : const LinearProgressIndicator(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: MediaQuery.of(context).size.width / 1.1,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 24, 24, 24),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: const Color.fromARGB(113, 158, 158, 158)),
                      ),
                      height: 50,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.4,
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 15),
                              decoration: const InputDecoration(
                                  hintText: "Message",
                                  hintStyle: TextStyle(
                                      fontSize: 15.0, color: Colors.white70),
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none),
                            ),
                          ),
                          const Spacer(),
                          SendMessageButton(
                            sendMessage: _postComment,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )),
          onRefresh: () async {
            _loadComments().then((value) => setState(() {
                  _isLoading = false;
                }));
          }),
    );
  }
}
