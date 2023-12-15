import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController inputController;
  final String inputLabel;
  final double? height, width;
  const PasswordField({
    super.key,
    required this.inputController,
    required this.inputLabel,
    this.height,
    this.width,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 7, right: 2, top: 2),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppColors.inputBackgroundColor,
        border: Border.all(
          color: const Color.fromARGB(255, 48, 48, 48),
          width: .7,
        ),
        borderRadius: BorderRadius.circular(2.5),
      ),
      height: widget.height ?? 47,
      width: widget.width ?? MediaQuery.of(context).size.width / 1.2,
      child: TextField(
          cursorHeight: 17,
          controller: widget.inputController,
          obscureText: !isVisible,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
          decoration: InputDecoration(
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  isVisible = !isVisible;
                });
              },
              child: !isVisible
                  ? const Icon(
                      Icons.visibility_off,
                      size: 16,
                    )
                  : const Icon(
                      Icons.visibility,
                      size: 16,
                    ),
            ),
            suffixIconColor: Colors.blue,
            labelText: widget.inputLabel,
            labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          )),
    );
  }
}
