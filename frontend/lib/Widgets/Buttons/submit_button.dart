import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

class SubmitButton extends StatelessWidget {
  final double? height, width;
  final String buttonText;
  final void Function() onClick;
  final Color backgroundColor;

  const SubmitButton(
      {super.key,
      this.height,
      this.width,
      this.backgroundColor = AppColors.primaryButtonColor,
      required this.buttonText,
      required this.onClick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Ink(
        height: height ?? 40,
        width: width ?? MediaQuery.of(context).size.width / 1.3,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}
