import 'package:flutter/material.dart';

class CircleProfileImage extends StatelessWidget {
  final String userImage;

  CircleProfileImage(this.userImage);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: !Uri.parse(userImage).isAbsolute
          ? Text(
              userImage,
            )
          : null,
      backgroundImage: Uri.parse(userImage).isAbsolute
          ? NetworkImage(
              userImage,
            )
          : null,
    );
  }
}
