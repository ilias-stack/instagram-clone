import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Widgets/App%20UI/message.dart';

import '../../../constants.dart';
import 'package:http/http.dart' as http;

class ChatMessages extends StatefulWidget {
  final Map<String, dynamic> conversation;
  const ChatMessages({super.key, required this.conversation});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  bool _isLoading = true;
  int page = 0;
  Future<void> _retreiveMessages() async {
    final url = "http://$serverIpAddress:5000";
    final getMessagesRequest = await http.get(Uri.parse(
        '$url/messages/getMessages?convoId=${widget.conversation["id"]}'));
    if (getMessagesRequest.statusCode == 200) {
      for (var message in jsonDecode(getMessagesRequest.body)) {
        _messages.add(Message(
            messageId: message["id"],
            direction: User.id == widget.conversation["senderId"]
                ? message["directionIsPositive"]
                : !message["directionIsPositive"],
            text: message["message"],
            postId: message["sharedPostId"],
            sendingTime: DateTime.parse(message["sendingTime"])));
      }
    }
  }

  Future<void> _checkNewMessages() async {
    final url = "http://$serverIpAddress:5000";
    final getNewMessagesRequest = await http.get(Uri.parse(
        '$url/messages/getMessagesSince?convoId=${widget.conversation["id"]}&messageId=${_messages.isNotEmpty ? _messages.last.messageId : 0}'));
    if (getNewMessagesRequest.statusCode == 200) {
      var latestMessages = jsonDecode(getNewMessagesRequest.body) as List;
      if (latestMessages.isNotEmpty) {
        for (var message in latestMessages) {
          _messages.add(Message(
              messageId: message["id"],
              direction: User.id == widget.conversation["senderId"]
                  ? message["directionIsPositive"]
                  : !message["directionIsPositive"],
              text: message["message"],
              sendingTime: DateTime.parse(message["sendingTime"])));
        }
        setState(() {
          _controller.animateTo(_controller.position.maxScrollExtent + 40,
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn);
        });
      }
    }
  }

  Future<void> _retreiveMoreMessages() async {
    setState(() {
      _isLoading = true;
    });
    final url = "http://$serverIpAddress:5000";
    final getMoreMessagesRequest = await http.get(Uri.parse(
        '$url/messages/getMessages?convoId=${widget.conversation["id"]}&page=$page'));
    if (getMoreMessagesRequest.statusCode == 200) {
      final tempOldMessages = [..._messages];
      _messages.clear();
      for (var message in jsonDecode(getMoreMessagesRequest.body)) {
        _messages.add(Message(
            messageId: message["id"],
            direction: User.id == widget.conversation["senderId"]
                ? message["directionIsPositive"]
                : !message["directionIsPositive"],
            text: message["message"],
            sendingTime: DateTime.parse(message["sendingTime"])));
      }
      _messages.addAll(tempOldMessages);
    }
  }

  late Timer _tmr;

  @override
  void initState() {
    super.initState();
    _retreiveMessages().then((value) => setState(() {
          _isLoading = false;
          page++;
        }));
    _tmr = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkNewMessages();
    });
  }

  @override
  void dispose() {
    _tmr.cancel();
    _controller.dispose();
    super.dispose();
  }

  final _messages = <Message>[];
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _controller,
      children: [
        IconButton(
            iconSize: 30,
            splashRadius: 30,
            color: Colors.white,
            onPressed: () {
              _retreiveMoreMessages().then((value) => setState(() {
                    page++;
                    _isLoading = false;
                  }));
            },
            icon: const Icon(
              Icons.more_horiz,
            )),
        if (!_isLoading)
          if (_messages.isNotEmpty)
            ..._messages
          else
            const Center(
              child: Icon(
                Icons.segment_rounded,
                size: 40,
                color: Colors.white,
              ),
            )
        else
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        const SizedBox(
          height: 80,
        )
      ],
    );
  }
}
