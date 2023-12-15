import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/constants.dart';
import 'package:http/http.dart' as http;

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final _seperationBox = const SizedBox(
    height: 30,
  );

  late bool isPrivate;
  @override
  void initState() {
    super.initState();
    isPrivate = User.accountStatus == "PRIVATE" ? true : false;
  }

  Future<void> _changeVisibility() async {
    String accountStatus = isPrivate ? "PRIVATE" : "PUBLIC";
    if (User.accountStatus != accountStatus) {
      final url = "http://$serverIpAddress:5000";
      final changeRequest = await http.get(
        Uri.parse(
            '$url/user/changeVisibility/${User.id}?visibility=$accountStatus'),
      );
      if (changeRequest.statusCode == 200) {
        // ignore: use_build_context_synchronously
        CoreMethods.showSnackBar(
            context, 'Visibility was updated to $accountStatus.');
        User.accountStatus = accountStatus;
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        CoreMethods.showSnackBar(context, 'An error has occured.');
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: _changeVisibility,
              icon: const Icon(
                Icons.check,
                color: Colors.blue,
              ))
        ],
        backgroundColor: AppColors.bottomBar,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Who can see your content',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
              style: AppTextStyles.primaryTextStyle
                  .copyWith(fontSize: 27, fontWeight: FontWeight.w700),
            ),
            _seperationBox,
            Text(
              'Who can see your content',
              style: AppTextStyles.primaryTextStyle.copyWith(fontSize: 25),
            ),
            _seperationBox,
            Text(
              'Account privacy',
              style: AppTextStyles.buttonTextStyle.copyWith(fontSize: 17),
            ),
            _seperationBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Private account',
                  style: AppTextStyles.primaryTextStyle.copyWith(fontSize: 17),
                ),
                CupertinoSwitch(
                  activeColor: Colors.blue,
                  value: isPrivate,
                  onChanged: (value) {
                    setState(() {
                      isPrivate = value;
                    });
                  },
                )
              ],
            ),
            _seperationBox,
            Text(
              "When your account is public, your profile and posts can be seen by anyone, on or off Instagram, even if they don’t have an Instagram account.",
              style: AppTextStyles.secondaryTextStyle.copyWith(fontSize: 15),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "When your account is private, only the followers you approve can see what you share and your followers and following lists. ",
              style: AppTextStyles.secondaryTextStyle.copyWith(fontSize: 15),
            )
          ],
        ),
      ),
    );
  }
}
