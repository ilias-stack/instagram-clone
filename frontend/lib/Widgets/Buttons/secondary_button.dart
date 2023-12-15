import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final void Function() onClick;
  final String text;
  final double width;
  const SecondaryButton(
      {super.key,
      required this.onClick,
      required this.text,
      this.width = double.maxFinite});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(
                const Color.fromARGB(255, 63, 63, 63)),
          ),
          onPressed: onClick,
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          )),
    );
  }
}
