import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Widgets/App%20UI/profile_search_result.dart';
import 'dart:convert';

import '../../constants.dart';
import 'package:http/http.dart' as http;

class SharePostModal extends StatefulWidget {
  final int postId;
  const SharePostModal({super.key, required this.postId});

  @override
  State<SharePostModal> createState() => _SharePostModalState();
}

class _SharePostModalState extends State<SharePostModal> {
  bool _isLoading = true;
  List<Widget> users = [];

  Future<void> _loadConversationDetails() async {
    _isLoading = true;
    users = [];
    final url = "http://$serverIpAddress:5000";
    final findConvosRequest = await http.get(
      Uri.parse('$url/messages/conversationsof?userId=${User.id}'),
    );
    if (findConvosRequest.statusCode == 200) {
      final convos = jsonDecode(findConvosRequest.body);
      for (final conversation in convos) {
        final getUserData = await http.get(
          Uri.parse(
              '$url/user/findUser/${conversation["conversation"]["receiverId"] == User.id ? conversation["conversation"]["senderId"] : conversation["conversation"]["receiverId"]}'),
        );
        if (getUserData.statusCode == 200) {
          final userData = jsonDecode(getUserData.body);
          users.add(
            GestureDetector(
              onTap: () async {
                final sharePostRequest = await http.post(
                    Uri.parse('$url/messages/sendMessage'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(<String, dynamic>{
                      "conversationId": conversation["conversation"]["id"],
                      "sharedPostId": widget.postId,
                      "directionIsPositive":
                          conversation["conversation"]["senderId"] == User.id,
                    }));
                if (sharePostRequest.statusCode == 200) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
              child: ProfileSearchResult(
                isClikable: false,
                fullName: userData["fullname"],
                profileId: userData["id"],
                userName: userData["username"],
                profilePictureId: userData["profilePictureId"],
              ),
            ),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadConversationDetails()
        .then((value) => setState(() => _isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? ListView(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Center(
                  child: Text(
                "Share",
                style: AppTextStyles.primaryTextStyle,
              )),
              const Divider(
                color: Colors.grey,
              ),
              if (users.isNotEmpty)
                ...users
              else
                const Center(
                  child: Text(
                    "No previous conversations were found.",
                    style: AppTextStyles.primaryTextStyle,
                  ),
                )
            ],
          )
        : const LinearProgressIndicator();
  }
}
