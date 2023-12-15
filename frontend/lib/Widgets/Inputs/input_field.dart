import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

class InputField extends StatelessWidget {
  final TextEditingController inputController;
  final String inputLabel;
  final TextInputType inputType;
  final bool bottomDecorated;
  final double? height, width;
  const InputField(
      {super.key,
      required this.inputController,
      required this.inputLabel,
      this.bottomDecorated = false,
      this.height,
      this.width,
      this.inputType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: !bottomDecorated
          ? const EdgeInsets.only(left: 7, right: 2, top: 2)
          : null,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: !bottomDecorated ? AppColors.inputBackgroundColor : null,
        border: !bottomDecorated
            ? Border.all(
                color: const Color.fromARGB(255, 48, 48, 48),
                width: .7,
              )
            : const Border(
                bottom: BorderSide(color: Colors.white, width: 1.3),
              ),
        borderRadius: !bottomDecorated ? BorderRadius.circular(2.5) : null,
      ),
      height: height ?? 47,
      width: width ?? MediaQuery.of(context).size.width / 1.2,
      child: TextField(
          cursorHeight: 17,
          controller: inputController,
          keyboardType: inputType,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
          decoration: InputDecoration(
            suffixIconColor: Colors.blue,
            labelText: inputLabel,
            labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          )),
    );
  }
}
