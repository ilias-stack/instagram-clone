import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Pages/Secondary%20Pages/Chat%20related/chat_page.dart';
import 'package:frontend/Widgets/Buttons/submit_button.dart';
import 'package:http/http.dart' as http;
import '../../../Widgets/App UI/profile_image.dart';
import '../../../constants.dart';
import 'posts_displayer.dart';

class UserReview extends StatelessWidget {
  final int userId;
  final String userName;
  const UserReview({super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.bottomBar,
          title: Text(
            userName,
            style: AppTextStyles.primaryTextStyle,
          )),
      body: UserReviewBody(userId: userId),
    );
  }
}

class UserReviewBody extends StatefulWidget {
  final int userId;
  const UserReviewBody({super.key, required this.userId});

  @override
  State<UserReviewBody> createState() => _UserReviewBodyState();
}

class _UserReviewBodyState extends State<UserReviewBody> {
  Map<String, dynamic>? userInfo;
  bool _followingIsSet = false;
  int postCount = 0, followCount = 0, followingCount = 0;

  Future<void> _retreiveFollowsDetails() async {
    final url = "http://$serverIpAddress:5000";
    final getFollowsRequest = await http
        .get(Uri.parse('$url/follows/followsCount?userId=${widget.userId}'));
    if (getFollowsRequest.statusCode == 200) {
      final followsNumber = jsonDecode(getFollowsRequest.body);
      setState(() {
        followCount = followsNumber["followers"];
        followingCount = followsNumber["followings"];
      });
    }
  }

  Future<void> _retreiveUserInfo(int id) async {
    final url = "http://$serverIpAddress:5000";
    final getInfoRequest =
        await http.get(Uri.parse('$url/user/findUser/${widget.userId}'));
    if (getInfoRequest.statusCode == 200) {
      userInfo = jsonDecode(getInfoRequest.body);
    } else {
      userInfo = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _retreiveUserInfo(widget.userId).then((value) {
      setState(() {
        followButton.followingId = userInfo?["id"];
        _followingIsSet = true;
      });
    });
    _retreiveFollowsDetails();
  }

  final followButton = FollowButton(
    followingId: -1,
  );

  Future<Map<String, dynamic>?> _gotoConversation() async {
    final url = "http://$serverIpAddress:5000";
    final postConversation = await http.post(
        Uri.parse('$url/messages/createConvo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          "senderId": User.id,
          "receiverId": widget.userId
        }));
    if (postConversation.statusCode == 200) {
      final conversation = jsonDecode(postConversation.body);
      return (conversation as Map<String, dynamic>);
    }
    // ignore: use_build_context_synchronously
    CoreMethods.showSnackBar(context, "Please try again later.");
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(
          height: 15,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileImage(imageId: userInfo?["profilePictureId"]),
            const SizedBox(
              width: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userInfo?["username"] ?? "Loading",
                    style:
                        AppTextStyles.primaryTextStyle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  User.id != widget.userId
                      ? Row(
                          children: [
                            _followingIsSet
                                ? followButton
                                : const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                            const SizedBox(
                              width: 10,
                            ),
                            IconButton(
                              splashRadius: 20,
                              splashColor: Colors.blue,
                              onPressed: () {
                                _gotoConversation().then((value) => value !=
                                        null
                                    ? Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                                  conversation: value["data"],
                                                  receiver: value["receiver"],
                                                )))
                                    : null);
                              },
                              icon: const Icon(
                                Icons.message,
                                color: Colors.white,
                              ),
                            )
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userInfo?['fullname'] ?? "Loading",
                style: AppTextStyles.buttonTextStyle,
              ),
              const SizedBox(
                height: 10,
              ),
              userInfo?['description'] != null && userInfo?['description'] != ''
                  ? Text(
                      userInfo?['description'] ?? "Loading",
                      style: AppTextStyles.primaryTextStyle,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(
          thickness: 1.5,
          color: Color.fromARGB(255, 48, 48, 48),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  postCount.toString(),
                  style: AppTextStyles.primaryTextStyle,
                ),
                const Text(
                  'posts',
                  style: AppTextStyles.secondaryTextStyle,
                )
              ],
            ),
            Column(
              children: [
                Text(
                  followCount.toString(),
                  style: AppTextStyles.primaryTextStyle,
                ),
                const Text(
                  'followers',
                  style: AppTextStyles.secondaryTextStyle,
                )
              ],
            ),
            Column(
              children: [
                Text(
                  followingCount.toString(),
                  style: AppTextStyles.primaryTextStyle,
                ),
                const Text(
                  'folllowing',
                  style: AppTextStyles.secondaryTextStyle,
                )
              ],
            )
          ],
        ),
        const Divider(
          thickness: 1.5,
          color: Color.fromARGB(255, 48, 48, 48),
        ),
        PostsDisplayer(
          userId: widget.userId,
          postsCountUpdater: (int n) {
            setState(() {
              postCount = n;
            });
          },
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class FollowButton extends StatefulWidget {
  int followingId;
  FollowButton({super.key, required this.followingId});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkFollow().then((value) => setState(() {
          _isLoading = false;
        }));
  }

  Future<void> _checkFollow() async {
    final url = "http://$serverIpAddress:5000";
    final getFollowStatusRequest = await http.get(Uri.parse(
        '$url/follows/followcheck?follower=${User.id}&following=${widget.followingId}'));
    if (getFollowStatusRequest.statusCode == 200) {
      _isFollowing = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? SubmitButton(
            width: 120,
            onClick: () async {
              setState(() {
                _isLoading = true;
              });
              final url = "http://$serverIpAddress:5000";
              final http.Response myRequest;
              final body = jsonEncode(<String, int>{
                "follower": User.id!,
                "following": widget.followingId
              });
              final headers = {'Content-Type': 'application/json'};
              if (_isFollowing) {
                myRequest = await http.post(
                  Uri.parse('$url/follows/unfollow'),
                  headers: headers,
                  body: body,
                );
              } else {
                myRequest = await http.post(
                  Uri.parse('$url/follows/follow'),
                  headers: headers,
                  body: body,
                );
              }
              if (myRequest.statusCode == 200) {
                _isFollowing = !_isFollowing;
              }
              setState(() {
                _isLoading = false;
              });
            },
            buttonText: !_isFollowing ? "Follow" : "Unfollow",
            backgroundColor:
                !_isFollowing ? AppColors.primaryButtonColor : Colors.white12,
          )
        : const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
  }
}
