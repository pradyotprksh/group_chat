import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';

class ReceivedInviteList extends StatelessWidget {
  final DocumentSnapshot inviteDetails;
  final Function updateInviteList;

  ReceivedInviteList(this.inviteDetails, this.updateInviteList);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ListTile(
                leading: Icon(
                  Icons.access_time,
                ),
                title: Text(
                  "On ${Utility.getTimeFromTimeStamp(inviteDetails.get(FirestoreConstants.INVITE_ON))}",
                  style: GoogleFonts.asap(),
                ),
                subtitle: Text(
                  "Got invitation from ${inviteDetails.get(FirestoreConstants
                      .USER_NAME)} for the group ${inviteDetails.get(
                      FirestoreConstants.GROUP_NAME)}",
                  style: GoogleFonts.asap(),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 15.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RaisedButton(
                onPressed: () {
                  updateInviteList(inviteDetails, 1);
                },
                color: Colors.green,
                child: Text('Accept'),
              ),
              const SizedBox(
                width: 15.0,
              ),
              RaisedButton(
                onPressed: () {
                  updateInviteList(inviteDetails, 0);
                },
                child: Text('Reject'),
              ),
            ],
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
