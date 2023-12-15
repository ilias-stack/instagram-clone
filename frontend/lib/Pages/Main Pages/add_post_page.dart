import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Models/user_model.dart';
import 'package:frontend/Widgets/App%20UI/add_post.dart';
import 'package:frontend/Widgets/Buttons/submit_button.dart';
import 'package:frontend/Widgets/Inputs/text_area.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart' as mime;

import '../../constants.dart';

class AddPostPage extends StatefulWidget {
  final void Function() goBack;
  const AddPostPage({super.key, required this.goBack});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  late final TextEditingController _descriptionController;
  late bool isUploading;
  final _imagesState = GlobalKey<AddPostCollectionState>();

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    isUploading = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(
          height: 30,
        ),
        AddPostCollection(
          key: _imagesState,
        ),
        const SizedBox(
          height: 15,
        ),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 1.05,
            child: TextArea(
                inputController: _descriptionController,
                inputLabel: 'Write a caption...'),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        !isUploading
            ? SubmitButton(
                buttonText: "Share",
                onClick: () async {
                  final pickedImages = _imagesState.currentState!.images;
                  setState(() {
                    isUploading = true;
                  });
                  final url = "http://$serverIpAddress:5000";
                  if (pickedImages != null) {
                    final creatPostRequest =
                        await http.post(Uri.parse('$url/posts/create'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode(<String, dynamic>{
                              "length": pickedImages.length,
                              "description": _descriptionController.text.isEmpty
                                  ? null
                                  : _descriptionController.text,
                              "userId": User.id
                            }));
                    if (creatPostRequest.statusCode == 200) {
                      final postId = jsonDecode(creatPostRequest.body)["id"];
                      print(postId);
                      for (final image in pickedImages) {
                        final imageUploadRequest = http.MultipartRequest(
                            'POST', Uri.parse('$url/posts/postImage'));
                        final mimeType = mime.lookupMimeType(image.path);
                        final fileLength = await image.length();
                        imageUploadRequest.files.add(http.MultipartFile(
                            'file', image.readAsBytes().asStream(), fileLength,
                            filename: image.path.split('/').last,
                            contentType: MediaType(mimeType!.split('/').first,
                                mimeType.split('/').last)));
                        imageUploadRequest.fields['postId'] = postId.toString();
                        final response = await imageUploadRequest.send();
                        if (response.statusCode != 200) {
                          print(response.statusCode);
                          setState(() {
                            isUploading = false;
                          });
                          if (context.mounted) {
                            CoreMethods.showSnackBar(context,
                                "An error has occured while uploading images.");
                          }
                          return;
                        }
                      }
                      widget.goBack();
                    } else {
                      if (context.mounted) {
                        CoreMethods.showSnackBar(
                            context, "An error has occured.");
                      }
                    }
                  } else {
                    if (context.mounted) {
                      CoreMethods.showSnackBar(
                          context, "Your post should contain some photos.");
                    }
                  }
                  setState(() {
                    isUploading = false;
                    _imagesState.currentState!.images = null;
                    _descriptionController.text = '';
                  });
                })
            : const Center(
                child: SizedBox(
                  height: 40,
                  child: Center(
                    child: SizedBox(
                      height: 5,
                      child: LinearProgressIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
