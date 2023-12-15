import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/Pages/Connection%20Pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

//! ALWAYS REMEMBER TO RUN ../setup.py
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instagram',
      theme: ThemeData(
          fontFamily: 'Instagram Sans',
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.transparent)),
      home: const LoginPage(),
    );
  }
}
