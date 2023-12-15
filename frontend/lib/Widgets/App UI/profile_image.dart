import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';

class ProfileImage extends StatelessWidget {
  final int? imageId;
  final double size;
  final XFile? image;
  final double padding;
  const ProfileImage(
      {super.key,
      required this.imageId,
      this.size = 50,
      this.image,
      this.padding = 8});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black26,
              width: 1.0,
            )),
        child: CircleAvatar(
          radius: size,
          backgroundColor: const Color.fromARGB(255, 70, 70, 70),
          child: ClipOval(
            child: imageId != null || image != null
                ? AspectRatio(
                    aspectRatio: 1,
                    child: image == null
                        ? Image.network(
                            'http://$serverIpAddress:5000/media/ProfilePic/$imageId',
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(image!.path),
                            fit: BoxFit.cover,
                          ),
                  )
                : Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: size,
                  ),
          ),
        ),
      ),
    );
  }
}
