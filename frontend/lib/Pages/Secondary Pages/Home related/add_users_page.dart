import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Widgets/App%20UI/profile_search_result.dart';
import 'package:frontend/constants.dart';
import 'package:http/http.dart';

class AddUsersPage extends StatefulWidget {
  const AddUsersPage({super.key});

  @override
  State<AddUsersPage> createState() => _AddUsersPageState();
}

class _AddUsersPageState extends State<AddUsersPage> {
  bool _isLoading = true;

  final _users = <Widget>[];

  Future<void> _getUsers() async {
    final url = "http://$serverIpAddress:5000";
    final suggestedUsersGetRequest =
        await get(Uri.parse('$url/user/suggestUsersFor?userId=${User.id}'));
    if (suggestedUsersGetRequest.statusCode == 200) {
      for (var user in jsonDecode(suggestedUsersGetRequest.body)) {
        _users.add(ProfileSearchResult(
          fullName: user["fullname"],
          profileId: user["id"],
          userName: user["username"],
          profilePictureId: user["profilePictureId"],
        ));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUsers().then((value) => setState(() => _isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bottomBar,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Discover people',
          style: AppTextStyles.primaryTextStyle,
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : _users.isNotEmpty
              ? ListView(
                  children: _users,
                )
              : const Center(
                  child: Text(
                    "No users were suggested for you.",
                    style: AppTextStyles.primaryTextStyle,
                  ),
                ),
    );
  }
}
