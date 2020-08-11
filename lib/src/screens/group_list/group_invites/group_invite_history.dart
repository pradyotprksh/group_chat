import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class GroupInviteHistory extends StatefulWidget {
  final Function updateInviteList;

  GroupInviteHistory(this.updateInviteList);

  @override
  _GroupInviteHistoryState createState() => _GroupInviteHistoryState();
}

class _GroupInviteHistoryState extends State<GroupInviteHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        leading: CloseButton(),
        title: Text(
          "History",
          style: GoogleFonts.asap(),
        ),
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (_, currentUserSnapshot) {
          if (currentUserSnapshot.connectionState == ConnectionState.waiting) {
            return CenterCircularProgressBar();
          } else if (currentUserSnapshot.data == null) {
            return CenterText("Not able to get your data. Please try again,");
          } else {
            return StreamBuilder(
              stream: Firestore.instance
                  .collection(FirestoreConstants.USER)
                  .document(currentUserSnapshot.data.uid)
                  .collection(FirestoreConstants.GROUPS_INVITE)
                  .orderBy(
                    FirestoreConstants.INVITE_ON,
                    descending: true,
                  )
                  .snapshots(),
              builder: (_, groupsInviteSnapshot) {
                if (groupsInviteSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CenterCircularProgressBar();
                } else if (groupsInviteSnapshot.data == null) {
                  return CenterText(
                      "Not able to get your data. Please try again,");
                } else {
                  var groupsInvite = groupsInviteSnapshot.data.documents;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: groupsInvite.length,
                    itemBuilder: (_, position) {
                      return FutureBuilder(
                        future: Firestore.instance
                            .document(
                              groupsInvite[position]
                                      [FirestoreConstants.INVITE_ID]
                                  .path,
                            )
                            .get(),
                        builder: (_, inviteDetails) {
                          if (inviteDetails.connectionState ==
                                  ConnectionState.done &&
                              inviteDetails.data != null) {
                            if (inviteDetails.data[
                                    FirestoreConstants.GROUP_INVITE_ACCEPTED] ||
                                inviteDetails
                                    .data[FirestoreConstants.IS_REJECTED]) {
                              return Column(
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      Icons.access_time,
                                    ),
                                    title: Text(
                                      "On ${Utility.getTimeFromTimeStamp(inviteDetails.data[FirestoreConstants.INVITE_ON])}",
                                      style: GoogleFonts.asap(),
                                    ),
                                    subtitle: Text(
                                      (inviteDetails.data[FirestoreConstants
                                                  .GROUP_INVITE_BY] !=
                                              currentUserSnapshot.data.uid)
                                          ? (inviteDetails.data[
                                                  FirestoreConstants
                                                      .GROUP_INVITE_ACCEPTED])
                                              ? "You accepted the request from ${inviteDetails.data[FirestoreConstants.USER_NAME]} who wanted to join ${inviteDetails.data[FirestoreConstants.GROUP_NAME]}"
                                              : "You rejected the request from ${inviteDetails.data[FirestoreConstants.USER_NAME]} who wanted to join ${inviteDetails.data[FirestoreConstants.GROUP_NAME]}"
                                          : (inviteDetails.data[
                                                  FirestoreConstants
                                                      .GROUP_INVITE_ACCEPTED])
                                              ? "Your request to join ${inviteDetails.data[FirestoreConstants.GROUP_NAME]} was accepted"
                                              : "Your request to join ${inviteDetails.data[FirestoreConstants.GROUP_NAME]} was rejected",
                                      style: GoogleFonts.asap(
                                        color: (inviteDetails.data[
                                                FirestoreConstants
                                                    .GROUP_INVITE_ACCEPTED])
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                  if ((inviteDetails.data[FirestoreConstants
                                              .GROUP_INVITE_BY] ==
                                          currentUserSnapshot.data.uid) &&
                                      !inviteDetails.data[FirestoreConstants
                                          .GROUP_INVITE_ACCEPTED])
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                      ),
                                      child: RaisedButton(
                                        onPressed: () async {
                                          await widget.updateInviteList(
                                              inviteDetails.data, 3);
                                          setState(() {});
                                        },
                                        color: Colors.orange,
                                        child: Text('Send Again.'),
                                      ),
                                    ),
                                  Divider(
                                    thickness: 1,
                                    color: Colors.grey,
                                  ),
                                ],
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
