import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/group_chat/circle_profile_image.dart';
import 'package:group_chat/src/screens/profile_details_bottom_sheet.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';
import 'package:url_launcher/url_launcher.dart';

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
              onTap: () {
                Get.bottomSheet(
                  ProfileDetailsBottomSheet(snapshot),
                );
              },
              child: CircleProfileImage(
                snapshot[FirestoreConstants.USER_PROFILE_PIC],
              ),
            ),
          const SizedBox(
            width: 15,
          ),
          Container(
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
            child: SelectableLinkify(
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                } else {
                  Utility.showSnackBar(
                      "Seems like the link is broken.", Colors.red);
                }
              },
              text: "${snapshot[FirestoreConstants.MESSAGE]}",
              style:
                  GoogleFonts.asap(color: isMe ? Colors.black : Colors.white),
              linkStyle: GoogleFonts.asap(
                color: isMe ? Colors.indigoAccent : Colors.white,
              ),
              options: LinkifyOptions(
                humanize: false,
              ),
              textAlign: isMe ? TextAlign.end : TextAlign.start,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          if (isMe)
            CircleProfileImage(
              snapshot[FirestoreConstants.USER_PROFILE_PIC],
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
