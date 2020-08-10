import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/group_chat/circle_profile_image.dart';
import 'package:group_chat/src/util/firestore_constants.dart';

class Message extends StatelessWidget {
  final bool isMe;
  final DocumentSnapshot snapshot;
  final double screenWidth;

  Message(this.isMe, this.snapshot, this.screenWidth);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 15.0,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            const SizedBox(
              width: 15,
            ),
          if (!isMe)
            GestureDetector(
              child: CircleProfileImage(
                snapshot[FirestoreConstants.USER_PROFILE_PIC],
              ),
            ),
          const SizedBox(
            width: 15,
          ),
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: isMe ? Colors.grey[300] : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomRight: !isMe ? Radius.circular(12) : Radius.circular(0),
                ),
              ),
              constraints: BoxConstraints(
                maxWidth: (screenWidth / 2) - 10,
              ),
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              child: Text(
                snapshot[FirestoreConstants.MESSAGE],
                textAlign: isMe ? TextAlign.end : TextAlign.start,
                style:
                    GoogleFonts.asap(color: isMe ? Colors.black : Colors.white),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          if (isMe)
            GestureDetector(
              child: CircleProfileImage(
                snapshot[FirestoreConstants.USER_PROFILE_PIC],
              ),
            ),
          if (isMe)
            const SizedBox(
              width: 15,
            ),
        ],
      ),
    );
  }
}
