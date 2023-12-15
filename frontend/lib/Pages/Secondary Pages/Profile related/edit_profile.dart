// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Widgets/App%20UI/profile_image.dart';
import 'package:frontend/Widgets/Buttons/submit_button.dart';
import 'package:frontend/Widgets/Inputs/input_field.dart';
import 'package:frontend/Widgets/Inputs/text_area.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart' as mime;

import '../../../constants.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _seperationBox = const SizedBox(
    height: 30,
  );

  late final TextEditingController _nameController;
  late final TextEditingController _userNameController;
  late final TextEditingController _descriptionController;
  late final ImagePicker _picker;
  XFile? pickedImage;
  int? _currentPhotoID;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    _nameController = TextEditingController();
    _userNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _nameController.text = User.fullName!;
    _userNameController.text = User.userName!;
    _descriptionController.text = User.description ?? "";
    _currentPhotoID = User.profilePictureId;
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _userNameController.dispose();
  }

  Future<void> _updateData() async {
    setState(() {
      isLoading = true;
    });
    final url = "http://$serverIpAddress:5000";
    final body = <String, String?>{
      "username": _userNameController.text.trim(),
      "fullname": _nameController.text.trim(),
      "description": _descriptionController.text,
    };
    if (pickedImage == null) {
      if (_currentPhotoID != User.profilePictureId) {
        body["profilePictureId"] = null;
      }
    } else {
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
        body["profilePictureId"] = await response.stream.bytesToString();
      } else {
        CoreMethods.showSnackBar(context, 'An error occured.');
        return;
      }
    }

    final updateRequest = await http.put(
      Uri.parse('$url/user/updateData/${User.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (updateRequest.statusCode == 200) {
      User.fillInformationFields(jsonDecode(updateRequest.body));
      CoreMethods.showSnackBar(context, 'User informations were updated!');
      Navigator.pop(context);
      return;
    } else {
      String? msg;
      if (updateRequest.body == "Username") {
        msg = "This username is already in use!";
      }
      CoreMethods.showSnackBar(context, msg ?? 'An error occured.');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.bottomBar,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Edit profile',
            style: TextStyle(fontSize: 16),
          ),
        ),
        body: ListView(
          children: [
            _seperationBox,
            Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileImage(
                  imageId: _currentPhotoID,
                  size: 70,
                  image: pickedImage,
                ),
                TextButton(
                    onPressed: () {
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
                                    (TextButton(
                                      onPressed: () {
                                        _currentPhotoID ==
                                                    User.profilePictureId ||
                                                pickedImage != null
                                            ? setState(() {
                                                pickedImage = null;
                                                _currentPhotoID = null;
                                                Navigator.pop(context);
                                              })
                                            : setState(() {
                                                _currentPhotoID =
                                                    User.profilePictureId;
                                                Navigator.pop(context);
                                              });
                                      },
                                      child: Text(
                                        _currentPhotoID == User.profilePictureId
                                            ? 'Delete current photo'
                                            : "Undo",
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    ))
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    child: const Text(
                      'Change Profile Photo',
                      style: TextStyle(fontSize: 19),
                    ))
              ],
            )),
            Center(
              child: InputField(
                bottomDecorated: true,
                inputController: _nameController,
                inputLabel: 'Name',
                width: MediaQuery.of(context).size.width / 1.17,
              ),
            ),
            Center(
              child: InputField(
                bottomDecorated: true,
                inputController: _userNameController,
                inputLabel: 'Username',
                width: MediaQuery.of(context).size.width / 1.17,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: TextArea(
                  inputController: _descriptionController,
                  width: MediaQuery.of(context).size.width / 1.15,
                  inputLabel: 'Description'),
            ),
            _seperationBox,
            Center(
                child: !isLoading
                    ? SubmitButton(
                        buttonText: 'Submit',
                        onClick: () => _updateData().then((value) {
                              setState(() {
                                isLoading = false;
                              });
                            }))
                    : const CircularProgressIndicator(
                        color: Colors.white,
                      )),
          ],
        ));
  }
}
