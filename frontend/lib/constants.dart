// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String serverIpAddress = '192.168.0.172';

class AppColors {
  static const backgroundColor = Color.fromARGB(255, 38, 38, 38);
  static const inputBackgroundColor = Color.fromARGB(255, 26, 26, 26);
  static const inputChildrenColor = Color.fromARGB(255, 150, 150, 150);
  static const primaryButtonColor = Color.fromARGB(255, 11, 116, 184);
  static const primaryTextColor = Colors.white;
  static const secondaryTextColor = Colors.white38;
  static const bottomBar = Color.fromARGB(255, 27, 27, 27);
}

class AppTextStyles {
  static const primaryTextStyle = TextStyle(color: AppColors.primaryTextColor);
  static const buttonTextStyle =
      TextStyle(color: AppColors.primaryTextColor, fontWeight: FontWeight.w900);
  static const secondaryTextStyle = TextStyle(
      color: AppColors.secondaryTextColor, fontWeight: FontWeight.w200);
}

class CoreMethods {
  static void redirectToPage(BuildContext context, Widget page) =>
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => page,
        ),
      );

  static void showSnackBar(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1200),
      ));
}

late final SharedPreferences prefs;
