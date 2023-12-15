import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Widgets/App%20UI/conversation_preview.dart';
import 'package:frontend/constants.dart';
import 'package:http/http.dart' as http;

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List? _conversations;
  bool _isLoading = true;

  Future<void> _retreiveConversations() async {
    final url = "http://$serverIpAddress:5000";
    final getConvosRequest = await http
        .get(Uri.parse('$url/messages/conversationsof?userId=${User.id}'));
    if (getConvosRequest.statusCode == 200) {
      _conversations = jsonDecode(getConvosRequest.body);
    }
  }

  @override
  void initState() {
    super.initState();
    _retreiveConversations().then((value) => setState(() {
          _isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? _conversations != null
            ? _conversations!.isNotEmpty
                ? ListView.builder(
                    itemCount: _conversations!.length,
                    itemBuilder: (context, index) => ConversationPreview(
                      onDelete: () =>
                          setState(() => _conversations!.removeAt(index)),
                      convoDetails: _conversations![index],
                    ),
                  )
                : const Center(
                    child: Text(
                      "You have no conversations yet!",
                      style: AppTextStyles.primaryTextStyle,
                    ),
                  )
            : const Center(
                child: Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 50,
                ),
              )
        : const Center(
            child: CircularProgressIndicator(
            color: Colors.white,
          ));
  }
}
