// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/Pages/Connection%20Pages/login_page.dart';
import 'package:frontend/Pages/main_page.dart';
import 'package:frontend/Widgets/Buttons/submit_button.dart';
import 'package:frontend/Widgets/Inputs/birthday_field.dart';
import 'package:frontend/Widgets/Inputs/input_field.dart';
import 'package:frontend/Widgets/Inputs/password_field.dart';
import 'package:frontend/Widgets/Inputs/text_area.dart';
import 'package:frontend/constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart' as mime;

import '../../Models/user_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final PageController _pageController;
  late final TextEditingController _emailController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _usernameController;
  late final TextEditingController _descriptionController;
  late final ImagePicker _picker;
  XFile? pickedImage;

  bool isFetching = false;

  final GlobalKey<BirthdayFieldState> _key = GlobalKey<BirthdayFieldState>();

  DateTime? birthDay;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _emailController = TextEditingController();
    _fullNameController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
    _descriptionController = TextEditingController();
    _picker = ImagePicker();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _descriptionController.dispose();
  }

  get _nextStepButton =>
      ({required void Function() onClick}) => GestureDetector(
            onTap: onClick,
            child: const CircleAvatar(
              backgroundColor: AppColors.primaryButtonColor,
              child: Center(
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          );

  get _emailHelperButton => (String domain) {
        return GestureDetector(
          onTap: () => !_emailController.text.contains('@')
              ? _emailController.text += domain
              : 0,
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.5),
              color: const Color.fromARGB(255, 51, 51, 51),
            ),
            child: Text(
              domain,
              style: AppTextStyles.primaryTextStyle,
            ),
          ),
        );
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        children: [
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const SizedBox(
                height: 100,
              ),
              Image.asset(
                'assets/images/WhiteTextLogo.png',
                scale: 4,
              ),
              Center(
                child: Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  child: Text(
                    "Sign up to see photos and videos from your friends.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.secondaryTextStyle
                        .copyWith(fontSize: 17, fontWeight: FontWeight.normal),
                  ),
                ),
              ),
              const SizedBox(
                height: 17,
              ),
              Center(
                child: Column(
                  children: [
                    InputField(
                      inputController: _emailController,
                      inputLabel: 'Email Address',
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _emailHelperButton('@gmail.com'),
                        _emailHelperButton('@hotmail.com'),
                        _emailHelperButton('@outlook.com')
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              _nextStepButton(onClick: () {
                if (_emailController.text.contains('@')) {
                  _pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linear);
                } else {
                  CoreMethods.showSnackBar(context, 'Email must be correct!');
                }
              }),
              const Divider(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                        color: Color.fromARGB(255, 239, 247, 253),
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                  GestureDetector(
                    onTap: () =>
                        CoreMethods.redirectToPage(context, const LoginPage()),
                    child: const Text(
                      " Log in",
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
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const SizedBox(
                height: 70,
              ),
              Center(
                  child: Text(
                'Enter name and Password',
                style: AppTextStyles.primaryTextStyle.copyWith(fontSize: 19),
              )),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  'Add your name so friends can find you.',
                  style:
                      AppTextStyles.secondaryTextStyle.copyWith(fontSize: 17),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Center(
                child: InputField(
                    inputController: _fullNameController,
                    inputLabel: 'Full Name'),
              ),
              Center(
                child: PasswordField(
                  inputController: _passwordController,
                  inputLabel: 'Password',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              _nextStepButton(onClick: () {
                if (_passwordController.text.length >= 8) {
                  if (_fullNameController.text.length >= 5) {
                    _pageController.animateToPage(birthDay == null ? 2 : 3,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear);
                  } else {
                    CoreMethods.showSnackBar(context, 'Fullname is too short');
                  }
                } else {
                  CoreMethods.showSnackBar(context, 'Password is too short!');
                }
              })
            ],
          ),
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const SizedBox(
                height: 90,
              ),
              SizedBox(
                height: 170,
                child: Image.asset(
                  'assets/images/candle.png',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  'When were you born?',
                  style: AppTextStyles.primaryTextStyle.copyWith(
                    fontSize: 23,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  "This won't be part of your public profile.",
                  style: AppTextStyles.secondaryTextStyle,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                  child: BirthdayField(
                key: _key,
              )),
              const SizedBox(
                height: 15,
              ),
              _nextStepButton(onClick: () {
                birthDay = _key.currentState!.selectedDate();

                _pageController.animateToPage(3,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.linear);
              })
            ],
          ),
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const SizedBox(
                height: 90,
              ),
              Center(
                child: Text(
                  'Enter your informations.',
                  style: AppTextStyles.primaryTextStyle.copyWith(fontSize: 21),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.4,
                  child: Text(
                    'Pick a username, photo and a description so your friends can recognize you.',
                    textAlign: TextAlign.center,
                    style:
                        AppTextStyles.secondaryTextStyle.copyWith(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return Dialog(
                          backgroundColor: AppColors.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    pickedImage = await _picker.pickImage(
                                        source: ImageSource.camera);
                                    setState(() {
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: const Text('Take a picture'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    pickedImage = await _picker.pickImage(
                                        source: ImageSource.gallery);
                                    setState(() {
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: const Text('Choose from gallery'),
                                ),
                                pickedImage != null
                                    ? (TextButton(
                                        onPressed: () {
                                          setState(() {
                                            pickedImage = null;
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: const Text(
                                          'Delete selected photo',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ))
                                    : const SizedBox.shrink()
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color.fromARGB(255, 70, 70, 70),
                  child: ClipOval(
                    child: pickedImage != null
                        ? AspectRatio(
                            aspectRatio: 1,
                            child: Image.file(
                              File(pickedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.person,
                                  color: Color.fromARGB(255, 184, 184, 184),
                                  size: 40,
                                ),
                              ),
                              Center(
                                child: SizedBox(
                                  width: 70,
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Icon(
                                      Icons.add_circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Center(
                child: InputField(
                    inputController: _usernameController,
                    inputLabel: 'Username'),
              ),
              const SizedBox(
                height: 5,
              ),
              Center(
                child: TextArea(
                    inputController: _descriptionController,
                    inputLabel: 'Description'),
              ),
              const SizedBox(
                height: 25,
              ),
              Center(
                  child: !isFetching
                      ? SubmitButton(
                          width: 250,
                          buttonText: 'Create account',
                          onClick: _createAccount)
                      : const SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ))),
              const SizedBox(
                height: 30,
              ),
              TextButton(
                  onPressed: () {
                    _pageController.animateToPage(0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear);
                  },
                  child: const Text('Recap'))
            ],
          )
        ],
      ),
    );
  }

  Future<void> _createAccount() async {
    setState(() {
      isFetching = true;
    });
    final url = "http://$serverIpAddress:5000";
    if (pickedImage != null) {
      final request =
          http.MultipartRequest('POST', Uri.parse('$url/media/profilePic'));

      final mimeType = mime.lookupMimeType(pickedImage!.path);
      final fileLength = await pickedImage!.length();

      request.files.add(http.MultipartFile(
          'file', pickedImage!.readAsBytes().asStream(), fileLength,
          filename: pickedImage!.path.split('/').last,
          contentType:
              MediaType(mimeType!.split('/').first, mimeType.split('/').last)));
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final body = {
          "username": _usernameController.text.trim().toLowerCase(),
          "email": _emailController.text.trim().toLowerCase(),
          "password": _passwordController.text.trim(),
          "fullname": _fullNameController.text.trim(),
          "birthday": birthDay.toString(),
          "description": _descriptionController.text,
          "profilePictureId": responseBody
        };
        final signinRequest = await http.post(
          Uri.parse('$url/user/signin'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        if (signinRequest.statusCode == 200) {
          // Request was successful
          final responseBody = jsonDecode(signinRequest.body);
          await prefs.setString("cookie", signinRequest.headers["set-cookie"]!);

          User.fillInformationFields(responseBody);
          CoreMethods.redirectToPage(context, const MainPage());
          return;
        } else {
          String errorType = signinRequest.body;
          if (errorType == "Username") {
            CoreMethods.showSnackBar(context, 'Username already taken.');
          } else if (errorType == "Email") {
            CoreMethods.showSnackBar(context, 'Email already taken.');
            _pageController.animateToPage(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear);
          } else {
            CoreMethods.showSnackBar(context, 'An unknown error has occured.');
          }
          setState(() {
            isFetching = false;
          });
          return;
        }
      } else {
        CoreMethods.showSnackBar(context, 'Please try again later!');
        setState(() {
          isFetching = false;
        });
        return;
      }
    } else {
      final body = {
        "username": _usernameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        "fullname": _fullNameController.text.trim(),
        "birthday": birthDay.toString(),
        "description": _descriptionController.text,
      };
      final signinRequest = await http.post(
        Uri.parse('$url/user/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (signinRequest.statusCode == 200) {
        // Request was successful
        final responseBody = jsonDecode(signinRequest.body);
        await prefs.setString("cookie", signinRequest.headers["set-cookie"]!);

        User.fillInformationFields(responseBody);
        CoreMethods.redirectToPage(context, const MainPage());

        return;
      } else {
        String errorType = signinRequest.body;
        if (errorType == "Username") {
          CoreMethods.showSnackBar(context, 'Username already taken.');
        } else if (errorType == "Email") {
          CoreMethods.showSnackBar(context, 'Email already taken.');
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear);
        } else {
          CoreMethods.showSnackBar(context, 'An unknown error has occured.');
        }
        setState(() {
          isFetching = false;
        });
        return;
      }
    }
  }
}
