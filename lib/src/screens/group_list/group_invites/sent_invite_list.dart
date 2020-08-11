import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';

class SentInviteList extends StatelessWidget {
  final DocumentSnapshot inviteDetails;

  SentInviteList(this.inviteDetails);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.access_time,
          ),
          title: Text(
            "On ${Utility.getTimeFromTimeStamp(inviteDetails[FirestoreConstants.INVITE_ON])}",
            style: GoogleFonts.asap(),
          ),
          subtitle: Text(
            "Invitation sent to ${inviteDetails[FirestoreConstants.GROUP_NAME]}. Waiting for confirmation from the group owner. We will let you know when you have being allowed into the group. Thanks.",
            style: GoogleFonts.asap(),
          ),
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
      ],
    );
  }
}
