import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Pages/Connection%20Pages/account_recovery_page.dart';
import 'package:frontend/Pages/Connection%20Pages/signup_page.dart';
import 'package:frontend/Pages/main_page.dart';
import 'package:frontend/Widgets/Buttons/submit_button.dart';
import 'package:frontend/Widgets/Inputs/input_field.dart';
import 'package:frontend/Widgets/Inputs/password_field.dart';
import 'package:frontend/constants.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailLoginController = TextEditingController();

  final TextEditingController _passwordLoginController =
      TextEditingController();

  late bool isTryingToLogin;

  @override
  void initState() {
    super.initState();
    isTryingToLogin = true;
    _autoLogIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: null,
      body: !isTryingToLogin
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 150,
                  ),
                  Image.asset(
                    'assets/images/WhiteTextLogo.png',
                    scale: 4,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  InputField(
                      inputController: _emailLoginController,
                      inputType: TextInputType.emailAddress,
                      inputLabel: 'Email or username'),
                  PasswordField(
                    inputController: _passwordLoginController,
                    inputLabel: "Password",
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SubmitButton(
                    buttonText: 'Log in',
                    onClick: _login,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountRecoveryPage(
                              email: _emailLoginController.text),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                            color: Color.fromARGB(255, 206, 224, 238),
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    color: Color.fromARGB(255, 77, 77, 77),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                            color: Color.fromARGB(255, 239, 247, 253),
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const SignupPage(),
                            ),
                          );
                        },
                        child: const Text(
                          " Sign up",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          : const Center(
              child: SizedBox(
                  height: 90,
                  width: 90,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  )),
            ),
    );
  }

  Future<void> _autoLogIn() async {
    final url = "http://$serverIpAddress:5000";
    final loginRequest = await http.get(
      Uri.parse('$url/user/session'),
      headers: {"Cookie": prefs.getString('cookie') ?? ''},
    );
    if (loginRequest.statusCode == 200) {
      final responseBody = jsonDecode(loginRequest.body);
      User.fillInformationFields(responseBody);
      // ignore: use_build_context_synchronously
      CoreMethods.redirectToPage(context, const MainPage());
      return;
    }
    setState(() {
      isTryingToLogin = false;
    });
  }

  Future<void> _login() async {
    setState(() {
      isTryingToLogin = true;
    });

    final url = "http://$serverIpAddress:5000";
    final loginRequest = await http.get(
      Uri.parse(
          '$url/user/login?identifier=${_emailLoginController.text.trim()}&password=${_passwordLoginController.text}'),
    );
    if (loginRequest.statusCode == 200) {
      final responseBody = jsonDecode(loginRequest.body);
      await prefs.setString("cookie", loginRequest.headers["set-cookie"]!);
      User.fillInformationFields(responseBody);
      // ignore: use_build_context_synchronously
      CoreMethods.redirectToPage(context, const MainPage());
    } else {
      if (loginRequest.statusCode == 401) {
        // ignore: use_build_context_synchronously
        CoreMethods.showSnackBar(context, 'Wrong password.');
      } else {
        // ignore: use_build_context_synchronously
        CoreMethods.showSnackBar(context, 'Please check again.');
      }
      setState(() {
        isTryingToLogin = false;
      });
    }
  }
}
