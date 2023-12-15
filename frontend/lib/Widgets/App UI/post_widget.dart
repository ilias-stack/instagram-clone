import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Pages/Secondary%20Pages/Posts%20related/comments_page.dart';
import 'package:frontend/Widgets/App%20UI/post_images.dart';
import 'package:frontend/Widgets/App%20UI/profile_image.dart';
import 'package:frontend/Widgets/App%20UI/share_post_modal.dart';
import 'package:frontend/constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PostWidget extends StatefulWidget {
  final int postId;
  const PostWidget({super.key, required this.postId});
  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _showFullDescription = false;
  late Map<String, dynamic> _postDetails = {};
  bool _isLoading = true;
  bool _isLiked = false;
  bool _isSaved = false;
  int _likesCount = 0;
  int _commentsCount = 0;

  @override
  void initState() {
    super.initState();
    _getPostInfos().then((value) => setState(
          () {
            _isLoading = false;
          },
        ));
    _getLikeStatus().then((value) => setState(
          () {
            _isLiked = value ?? false;
          },
        ));
    _getSaveStatus().then((value) => setState(
          () {
            _isSaved = value ?? false;
          },
        ));
    _getLikesCount().then((value) => setState(
          () {
            _likesCount = value ?? 0;
          },
        ));
    _getCommentsCount().then((value) => setState(
          () {
            _commentsCount = value ?? 0;
          },
        ));
  }

  final _likeAnimationDuration = 200;

  final url = "http://$serverIpAddress:5000";
  late List imageIds;
  double _likeIconOpacity = 0;

  Future<void> _getPostInfos() async {
    final getPostDetailsRequest =
        await http.get(Uri.parse('$url/posts/${widget.postId}'));
    if (getPostDetailsRequest.statusCode == 200) {
      _postDetails = jsonDecode(getPostDetailsRequest.body);
      imageIds = _postDetails["PostImage"] ?? [];
    }
  }

  Future<bool?> _getLikeStatus() async {
    final getLikeStatus = await http.get(Uri.parse(
        '$url/posts/${widget.postId}/alreadyLikes?userId=${User.id}'));
    if (getLikeStatus.statusCode == 200) {
      return jsonDecode(getLikeStatus.body);
    }
    return null;
  }

  int currentImage = 1;

  Future<bool?> _getSaveStatus() async {
    final getLikeStatus = await http.get(Uri.parse(
        '$url/posts/${widget.postId}/alreadySaved?userId=${User.id}'));
    if (getLikeStatus.statusCode == 200) {
      return jsonDecode(getLikeStatus.body);
    }
    return null;
  }

  Future<void> savePost() async {
    if (!_isSaved) {
      final savePostRequest = await http.post(
          Uri.parse('$url/posts/${widget.postId}/savePost'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(<String, dynamic>{"userId": User.id}));
      if (savePostRequest.statusCode == 200) {
        setState(() {
          _isSaved = true;
        });
      }
    } else {
      final unSavePostRequest = await http.post(
          Uri.parse('$url/posts/${widget.postId}/unsavePost'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(<String, dynamic>{"userId": User.id}));
      if (unSavePostRequest.statusCode == 200) {
        setState(() {
          _isSaved = false;
        });
      }
    }
  }

  Future<int?> _getLikesCount() async {
    final getLikeCount =
        await http.get(Uri.parse('$url/posts/${widget.postId}/likesCount'));
    if (getLikeCount.statusCode == 200) {
      return jsonDecode(getLikeCount.body);
    }
    return null;
  }

  Future<int?> _getCommentsCount() async {
    final getLikeCount =
        await http.get(Uri.parse('$url/posts/${widget.postId}/commentsCount'));
    if (getLikeCount.statusCode == 200) {
      return jsonDecode(getLikeCount.body);
    }
    return null;
  }

  Future<void> likePost() async {
    if (!_isLiked) {
      final likePostRequest = await http.post(
          Uri.parse('$url/posts/${widget.postId}/likePost'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(<String, dynamic>{"userId": User.id}));
      if (likePostRequest.statusCode == 200) {
        setState(() {
          _isLiked = true;
          _likesCount++;
          _likeIconOpacity = 1;
        });
      }
    } else {
      final likePostRequest = await http.post(
          Uri.parse('$url/posts/${widget.postId}/unlikePost'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(<String, dynamic>{"userId": User.id}));
      if (likePostRequest.statusCode == 200) {
        setState(() {
          _isLiked = false;
          _likesCount--;
        });
      }
    }
  }

  void _openCommentsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(
          postId: widget.postId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 12,
                  ),
                  ProfileImage(
                    imageId: _postDetails["User"]["profilePictureId"],
                    size: 20,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    _postDetails["User"]["username"],
                    style: AppTextStyles.primaryTextStyle,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onDoubleTap: () => likePost().then((value) => Future.delayed(
                        Duration(
                          milliseconds: _likeAnimationDuration,
                        ), () {
                      setState(() {
                        _likeIconOpacity = 0;
                      });
                    })),
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Stack(
                    children: [
                      PostImages(
                        imagesIds: imageIds,
                        onScroll: (int k) {
                          setState(() {
                            currentImage = k + 1;
                          });
                        },
                      ),
                      AnimatedOpacity(
                        opacity: _likeIconOpacity,
                        curve: Curves.linear,
                        duration:
                            Duration(milliseconds: _likeAnimationDuration),
                        child: const Center(
                          child: Icon(
                            Icons.favorite,
                            color: Color.fromARGB(158, 255, 255, 255),
                            size: 100,
                          ),
                        ),
                      ),
                      _postDetails["length"] > 1
                          ? Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: const EdgeInsets.all(15),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  '$currentImage/${_postDetails["length"]}',
                                  style: AppTextStyles.primaryTextStyle,
                                ),
                              ))
                          : const SizedBox.shrink()
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () => likePost().then((value) => Future.delayed(
                            Duration(
                              milliseconds: _likeAnimationDuration,
                            ), () {
                          setState(() {
                            _likeIconOpacity = 0;
                          });
                        })),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: !_isLiked
                          ? const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _openCommentsPage,
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.backgroundColor,
                        builder: (context) => SharePostModal(
                          postId: widget.postId,
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.send_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      savePost();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: !_isSaved
                          ? const Icon(
                              Icons.archive_outlined,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.archive,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 17, bottom: 3),
                child: Text(
                  '$_likesCount likes',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                  onTap: () => setState(() {
                        _showFullDescription = !_showFullDescription;
                      }),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 17, bottom: 3, right: 5),
                    child: _showFullDescription
                        ? RichText(
                            text: TextSpan(children: [
                            TextSpan(
                              text: "${_postDetails["User"]["username"]} ",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: _postDetails["description"],
                              style: const TextStyle(color: Colors.white),
                            )
                          ]))
                        : RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(children: [
                              TextSpan(
                                text: "${_postDetails["User"]["username"]} ",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: _postDetails["description"],
                                style: const TextStyle(color: Colors.white),
                              )
                            ])),
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 17, top: 3),
                child: Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(_postDetails["publishingDate"])),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 17, top: 3, bottom: 3),
                child: TextButton(
                    onPressed: _openCommentsPage,
                    child: _commentsCount > 0
                        ? Text('View all $_commentsCount comments')
                        : const Text('Be the first to comment')),
              )
            ],
          )
        : const Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
  }
}
