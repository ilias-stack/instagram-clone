import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Pages/Secondary%20Pages/Profile%20related/edit_profile.dart';
import 'package:frontend/Pages/Secondary%20Pages/Profile%20related/profile_settings.dart';
import 'package:frontend/Widgets/App%20UI/profile_image.dart';
import 'package:frontend/Widgets/Buttons/secondary_button.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../Secondary Pages/Users related/posts_displayer.dart';

class OwnProfilePage extends StatefulWidget {
  const OwnProfilePage({super.key});

  @override
  State<OwnProfilePage> createState() => OwnProfilePageState();
}

class OwnProfilePageState extends State<OwnProfilePage> {
  int? posts = 0, followers = 0, folllowing = 0;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    _retreiveFollowsDetails();
  }

  void refreshPage() {
    setState(() {});
  }

  Future<void> _retreiveFollowsDetails() async {
    final url = "http://$serverIpAddress:5000";
    final getFollowsRequest = await http
        .get(Uri.parse('$url/follows/followsCount?userId=${User.id}'));
    if (getFollowsRequest.statusCode == 200) {
      final followsNumber = jsonDecode(getFollowsRequest.body);
      setState(() {
        followers = followsNumber["followers"];
        folllowing = followsNumber["followings"];
      });
    }
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
            ProfileImage(imageId: User.profilePictureId),
            const SizedBox(
              width: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        User.userName!,
                        style: AppTextStyles.primaryTextStyle
                            .copyWith(fontSize: 20),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileSettings(),
                          ),
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: SecondaryButton(
                      width: 120,
                      onClick: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfile(),
                        ),
                      ).then((value) {
                        setState(() {});
                      }),
                      text: "Edit profile",
                    ),
                  )
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
                User.fullName!,
                style: AppTextStyles.buttonTextStyle,
              ),
              const SizedBox(
                height: 10,
              ),
              User.description != null && User.description != ''
                  ? Text(
                      User.description!,
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
                  '$posts',
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
                  '$followers',
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
                  '$folllowing',
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
          userId: User.id!,
          postsCountUpdater: (int n) {
            setState(() {
              posts = n;
            });
          },
        )
      ],
    );
  }
}
