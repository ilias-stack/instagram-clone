import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Widgets/App%20UI/profile_search_result.dart';
import 'package:frontend/constants.dart';
import 'package:http/http.dart' as http;

class DiscoverAppBar extends StatefulWidget {
  const DiscoverAppBar({super.key});

  @override
  State<DiscoverAppBar> createState() => _DiscoverAppBarState();
}

class _DiscoverAppBarState extends State<DiscoverAppBar> {
  final _searchController = TextEditingController();

  List<Widget> users = [];

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  Future<void> _findUsers(String name) async {
    final url = "http://$serverIpAddress:5000";
    final findRequest = await http.get(
      Uri.parse('$url/user/findUsers/$name'),
    );
    if (findRequest.statusCode == 200) {
      final responseBody = jsonDecode(findRequest.body);
      users.clear();
      for (final user in responseBody) {
        users.add(
          ProfileSearchResult(
            fullName: user["fullname"],
            profileId: user["id"],
            userName: user["username"],
            profilePictureId: user["photo"],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bottomBar,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 1.1,
            height: 30,
            decoration: const BoxDecoration(
                color: Color.fromARGB(96, 71, 71, 71),
                borderRadius: BorderRadius.all(Radius.circular(6))),
            child: Center(
              child: Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  const Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          users.clear();
                        });
                      } else {
                        _findUsers(value).then((value) => setState(() {}));
                      }
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none),
                  )),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        users.clear();
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.black26,
                      size: 20,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  )
                ],
              ),
            ),
          ),
          const Divider(),
          if (users.isNotEmpty)
            ...users
          else if (_searchController.text.isNotEmpty)
            const SizedBox(
              height: 30,
              child: Text(
                "No users were found.",
                style: AppTextStyles.secondaryTextStyle,
              ),
            ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
