import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Pages/Secondary%20Pages/Chat%20related/chat_messages.dart';
import 'package:frontend/Widgets/App%20Bars/chat_appbar.dart';
import 'package:frontend/constants.dart';
import 'package:http/http.dart' as http;

import '../../../Widgets/App UI/send_message_button.dart';

class ChatPage extends StatelessWidget {
  final Map<String, dynamic> conversation, receiver;

  ChatPage({super.key, required this.conversation, required this.receiver});

  final _messageController = TextEditingController();

  Future<void> _sendMessage(BuildContext context) async {
    if (_messageController.text.isNotEmpty) {
      final url = "http://$serverIpAddress:5000";
      final postMessageRequest = await http.post(
        Uri.parse('$url/messages/sendMessage'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          "conversationId": conversation["id"],
          "directionIsPositive": conversation["senderId"] == User.id,
          "message": _messageController.text,
        }),
      );
      if (postMessageRequest.statusCode != 200) {
        // ignore: use_build_context_synchronously
        CoreMethods.showSnackBar(context, "Error occured while sending.");
        return;
      }
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
        receiver: receiver,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          ChatMessages(
            conversation: conversation,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: MediaQuery.of(context).size.width / 1.1,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 24, 24, 24),
                borderRadius: BorderRadius.circular(50),
                border:
                    Border.all(color: const Color.fromARGB(113, 158, 158, 158)),
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
                      onSubmitted: (value) => _sendMessage(context),
                      controller: _messageController,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 15),
                      decoration: const InputDecoration(
                          hintText: "Message",
                          hintStyle:
                              TextStyle(fontSize: 15.0, color: Colors.white70),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none),
                    ),
                  ),
                  const Spacer(),
                  SendMessageButton(
                    sendMessage: () => _sendMessage(context),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
