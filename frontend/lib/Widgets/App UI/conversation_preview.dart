import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Widgets/App%20UI/delete_confirmation_dialog.dart';
import 'package:frontend/Widgets/App%20UI/profile_image.dart';
import 'dart:convert';

import '../../Pages/Secondary Pages/Chat related/chat_page.dart';
import '../../constants.dart';
import 'package:http/http.dart' as http;

class ConversationPreview extends StatelessWidget {
  final Map<String, dynamic> convoDetails;
  final Function onDelete;
  const ConversationPreview(
      {super.key, required this.convoDetails, required this.onDelete});

  Future<Map<String, dynamic>?> _retreiveReceiverDetails() async {
    final url = "http://$serverIpAddress:5000";
    final getReceiverRequest = await http.get(Uri.parse(
        '$url/user/findUser/${User.id != convoDetails["conversation"]["senderId"] ? convoDetails["conversation"]["senderId"] : convoDetails["conversation"]["receiverId"]}'));
    if (getReceiverRequest.statusCode == 200) {
      return jsonDecode(getReceiverRequest.body);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _retreiveReceiverDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final receiver = snapshot.data!;
          return GestureDetector(
            onLongPress: () => showDialog(
                context: context,
                builder: (ctx) => DeleteConfirmationDialogue(
                      deletionText: "Delete this conversation",
                      onConfirm: () async {
                        final url = "http://$serverIpAddress:5000";
                        final getReceiverRequest = await http.get(Uri.parse(
                            '$url/messages/deleteConvo/${convoDetails["conversation"]["id"]}'));
                        if (getReceiverRequest.statusCode == 200) {
                          onDelete();
                        }
                      },
                    )),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatPage(
                        conversation: convoDetails["conversation"],
                        receiver: {
                          "profilePictureId": receiver["profilePictureId"],
                          "username": receiver["username"],
                          "isOnline": receiver['isOnline']
                        }))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileImage(imageId: receiver["profilePictureId"], size: 30),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Text(
                            receiver["username"],
                            style: AppTextStyles.primaryTextStyle,
                          ),
                          receiver["isOnline"]
                              ? const Text(
                                  "  Online",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold),
                                )
                              // ignore: dead_code
                              : const Text(
                                  "  Offline",
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold),
                                )
                        ],
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      convoDetails['lastMessage'].isNotEmpty
                          ? Text(
                              "${(convoDetails['conversation']['senderId'] == User.id && convoDetails['lastMessage'][0]['directionIsPositive']) || (convoDetails['conversation']['receiverId'] == User.id && !convoDetails['lastMessage'][0]['directionIsPositive']) ? "You" : receiver["username"]}: ${convoDetails['lastMessage'][0]['sharedPostId'] != null ? " shared a post." : convoDetails['lastMessage'][0]['message']}",
                              style: AppTextStyles.primaryTextStyle
                                  .copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                )
              ],
            ),
          );
        } else {
          return const Text('No receiver data available');
        }
      },
    );
  }
}

// ...
