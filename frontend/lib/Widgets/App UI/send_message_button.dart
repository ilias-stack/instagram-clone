import 'package:flutter/material.dart';

class SendMessageButton extends StatefulWidget {
  final Future<void> Function() sendMessage;
  const SendMessageButton({super.key, required this.sendMessage});

  @override
  State<SendMessageButton> createState() => _SendMessageButtonState();
}

class _SendMessageButtonState extends State<SendMessageButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? IconButton(
            iconSize: 20,
            splashRadius: 20,
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              widget.sendMessage().whenComplete(() => setState(() {
                    _isLoading = false;
                  }));
            },
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ))
        : const CircularProgressIndicator(
            color: Colors.white,
          );
  }
}
