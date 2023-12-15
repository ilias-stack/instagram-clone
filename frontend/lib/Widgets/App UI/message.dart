import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:intl/intl.dart';

import '../../Pages/Secondary Pages/Posts related/single_post_page.dart';

class Message extends StatelessWidget {
  final int messageId;
  final bool direction;
  final String? text;
  final int? postId;
  final DateTime sendingTime;
  const Message(
      {super.key,
      this.direction = true,
      this.text,
      this.postId,
      required this.sendingTime,
      required this.messageId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: direction ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 1.3),
            margin: const EdgeInsets.only(right: 5, left: 5, top: 15),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: direction ? Colors.blue : Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                postId != null
                    ? IconButton(
                        splashRadius: 20,
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SinglePostPage(postId: postId!))),
                        icon: const Icon(
                          Icons.ads_click_outlined,
                          color: Colors.white,
                        ),
                      )
                    : const SizedBox.shrink(),
                text != null
                    ? Text(
                        text!,
                        style: AppTextStyles.primaryTextStyle,
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
        Text(
          DateFormat('HH:mm dd-MM-yyyy').format(sendingTime),
          style: const TextStyle(fontSize: 10, color: Colors.white30),
        )
      ],
    );
  }
}
