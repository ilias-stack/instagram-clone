import 'package:flutter/material.dart';
import 'package:frontend/Pages/Secondary%20Pages/Users%20related/user_review.dart';
import 'package:frontend/Widgets/App%20UI/profile_image.dart';

class ProfileSearchResult extends StatelessWidget {
  final int profileId;
  final int? profilePictureId;
  final String userName, fullName;
  final bool isClikable;
  const ProfileSearchResult(
      {super.key,
      required this.fullName,
      this.isClikable = true,
      required this.profileId,
      this.profilePictureId,
      required this.userName});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-16, 0),
      child: ListTile(
        onTap: isClikable
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserReview(
                      userId: profileId,
                      userName: userName,
                    ),
                  ),
                )
            : null,
        leading: Transform.scale(
          scale: 1.13,
          child: ProfileImage(
            imageId: profilePictureId,
            padding: 0,
          ),
        ),
        title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(userName,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 17)),
        ),
        subtitle: Transform.translate(
            offset: const Offset(-20, 0),
            child: Text(
              fullName,
              style: const TextStyle(color: Colors.grey),
            )),
      ),
    );
  }
}
