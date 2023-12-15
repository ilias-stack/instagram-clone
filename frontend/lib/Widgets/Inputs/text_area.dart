import 'package:flutter/material.dart';

import '../../constants.dart';

class TextArea extends StatelessWidget {
  final TextEditingController inputController;
  final String inputLabel;
  final double? width;
  const TextArea({
    super.key,
    required this.inputController,
    required this.inputLabel,
    this.width,
  });

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
      width: width ?? MediaQuery.of(context).size.width / 1.2,
      child: TextField(
          cursorHeight: 17,
          maxLength: 150,
          maxLines: 6,
          buildCounter: (BuildContext context,
              {int? currentLength, int? maxLength, bool? isFocused}) {
            final color = (currentLength == maxLength)
                ? const Color.fromARGB(255, 158, 77, 77)
                : Colors.grey;
            return Text(
              '$currentLength/$maxLength',
              style: TextStyle(color: color),
            );
          },
          controller: inputController,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
          decoration: InputDecoration(
            alignLabelWithHint: true,
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
