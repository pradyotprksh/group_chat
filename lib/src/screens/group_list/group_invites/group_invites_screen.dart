import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/groups_controller.dart';
import 'package:group_chat/src/screens/group_list/group_invites/group_invite_history.dart';
import 'package:group_chat/src/screens/group_list/group_invites/recieved_invite_list.dart';
import 'package:group_chat/src/screens/group_list/group_invites/sent_invite_list.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class GroupInvitesScreen extends StatefulWidget {
  static const route_name = "group_invite_screen";

  @override
  _GroupInvitesScreenState createState() => _GroupInvitesScreenState();
}

class _GroupInvitesScreenState extends State<GroupInvitesScreen> {
  final GroupController _groupController = Get.find();

  void updateInviteList(DocumentSnapshot inviteDetails, int type) async {
    await _groupController.updateInviteStatus(inviteDetails, type);
    setState(() {});
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          "Groups Joined",
          style: GoogleFonts.asap(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.bottomSheet(GroupInviteHistory(updateInviteList));
            },
            icon: Icon(
              Icons.history,
            ),
          ),
        ],
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
                            if (!inviteDetails.data[
                                    FirestoreConstants.GROUP_INVITE_ACCEPTED] &&
                                !inviteDetails
                                    .data[FirestoreConstants.IS_REJECTED]) {
                              if (inviteDetails.data[
                                      FirestoreConstants.GROUP_INVITE_BY] !=
                                  currentUserSnapshot.data.uid) {
                                return ReceivedInviteList(
                                    inviteDetails.data, updateInviteList);
                              } else {
                                return SentInviteList(inviteDetails.data);
                              }
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
