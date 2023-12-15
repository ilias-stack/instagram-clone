// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frontend/Widgets/Buttons/submit_button.dart';
import 'package:frontend/Widgets/Inputs/input_field.dart';
import 'package:frontend/constants.dart';
import 'package:http/http.dart' as http;

class AccountRecoveryPage extends StatefulWidget {
  final String email;
  const AccountRecoveryPage({super.key, this.email = ''});

  @override
  State<AccountRecoveryPage> createState() => _AccountRecoveryPageState();
}

class _AccountRecoveryPageState extends State<AccountRecoveryPage> {
  final Divider theDivider = const Divider(
    color: Colors.grey,
  );

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = widget.email;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final fixedHeightSB = const SizedBox(
    height: 10,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
        title: Image.asset(
          'assets/images/WhiteTextLogo.png',
          scale: 6,
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              theDivider,
              const SizedBox(
                height: 40,
              ),
              theDivider,
              const SizedBox(
                height: 20,
              ),
              Image.asset(
                'assets/images/MailLock.png',
                scale: 3.5,
              ),
              fixedHeightSB,
              const Text(
                'Trouble logging in?',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 226, 248, 255)),
              ),
              fixedHeightSB,
              Center(
                child: Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  child: Text(
                    "Enter your email or username and we'll send you a link to change your account password.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.secondaryTextStyle.copyWith(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              fixedHeightSB,
              InputField(inputController: _controller, inputLabel: 'Email'),
              fixedHeightSB,
              SubmitButton(
                  buttonText: 'Send link',
                  onClick: () async {
                    final url = "http://$serverIpAddress:5000";
                    final recoveryRequest = await http.post(
                      Uri.parse('$url/user/recover/${_controller.text.trim()}'),
                    );
                    if (recoveryRequest.statusCode == 200) {
                      CoreMethods.showSnackBar(context, 'The email was sent.');
                      Navigator.pop(context);
                    } else if (recoveryRequest.statusCode == 404) {
                      CoreMethods.showSnackBar(
                          context, 'No associated account to this email.');
                    } else {
                      CoreMethods.showSnackBar(
                          context, 'An error occured, please try again.');
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
