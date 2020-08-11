import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/groups_controller.dart';
import 'package:group_chat/src/screens/group_chat/group_chat_screen.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class GroupDetailBottomSheet extends StatelessWidget {
  final String groupName;
  final GroupController _groupController = Get.find();

  GroupDetailBottomSheet(this.groupName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        leading: CloseButton(),
        title: Text(
          groupName,
          style: GoogleFonts.asap(),
        ),
      ),
      body: FutureBuilder(
        future: Firestore.instance
            .collection(FirestoreConstants.GROUPS)
            .document(groupName)
            .get(),
        builder: (_, groupSnapshot) {
          if (groupSnapshot.connectionState == ConnectionState.waiting) {
            return CenterCircularProgressBar();
          } else if (groupSnapshot.data == null) {
            return CenterText("Not able to get group data.");
          } else {
            var snapshot = groupSnapshot.data;
            return FutureBuilder(
              future: Firestore.instance
                  .collection(FirestoreConstants.GROUPS)
                  .document(groupName)
                  .collection(FirestoreConstants.USER)
                  .getDocuments(),
              builder: (_, groupUsersSnapshot) {
                if (groupUsersSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CenterCircularProgressBar();
                } else if (groupSnapshot.data == null) {
                  return CenterText("Not able to get group data.");
                } else {
                  return FutureBuilder(
                    future: Firestore.instance
                        .collection(FirestoreConstants.USER)
                        .document(snapshot[FirestoreConstants.CREATED_BY])
                        .get(),
                    builder: (_, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CenterCircularProgressBar();
                      } else if (userSnapshot.data == null) {
                        return CenterText("Not able to get group data.");
                      } else {
                        return FutureBuilder(
                          future: _groupController.isUserJoinedTheGroup(
                              snapshot[FirestoreConstants.GROUP_NAME]),
                          builder: (_, groupJoinedSnapshot) {
                            if (groupJoinedSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CenterCircularProgressBar();
                            } else if (groupJoinedSnapshot.data == null) {
                              return Container();
                            } else {
                              var userData = userSnapshot.data;
                              return Stack(
                                children: [
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.only(
                                      bottom: 50.0,
                                    ),
                                    child: Column(
                                      children: [
                                        FadeInImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            snapshot[FirestoreConstants
                                                .GROUP_BACKGROUND_IMAGE],
                                          ),
                                          placeholder: AssetImage(
                                              "assets/default_group_background.jpg"),
                                        ),
                                        Tooltip(
                                          message: "Go To Group",
                                          child: ListTile(
                                            onTap: () {
                                              Get.toNamed(
                                                  GroupChatScreen.route_name,
                                                  arguments: snapshot[
                                                  FirestoreConstants
                                                      .GROUP_NAME]);
                                            },
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Image.network(
                                                  snapshot[FirestoreConstants
                                                      .GROUP_PROFILE_IMAGE],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            trailing: Icon(
                                              Icons.arrow_right,
                                              color: Colors.white,
                                            ),
                                            title: Text(
                                              snapshot[FirestoreConstants
                                                  .GROUP_NAME],
                                              style: GoogleFonts.asap(
                                                  fontSize: 18.0),
                                            ),
                                            subtitle: Text(
                                              snapshot[FirestoreConstants
                                                  .GROUP_DESCRIPTION],
                                              style: GoogleFonts.asap(),
                                            ),
                                          ),
                                        ),
                                        Divider(),
                                        ListTile(
                                          title: Text(
                                            "Created On ${Utility
                                                .getTimeFromTimeStamp(
                                                snapshot[FirestoreConstants
                                                    .CREATED_ON])}",
                                          ),
                                          subtitle: Text(
                                              "By ${userData[FirestoreConstants
                                                  .USER_NAME]}"),
                                        ),
                                        ListTile(
                                          title: Text(
                                            "${groupUsersSnapshot.data.documents
                                                .length} users has joined the group",
                                          ),
                                          subtitle: Text(
                                              snapshot[FirestoreConstants
                                                  .GROUP_SIZE] ==
                                                  0
                                                  ? ""
                                                  : "${snapshot[FirestoreConstants
                                                  .GROUP_SIZE] -
                                                  groupUsersSnapshot.data
                                                      .documents
                                                      .length} space left"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!groupJoinedSnapshot.data)
                                    if (snapshot[FirestoreConstants
                                        .GROUP_SIZE] !=
                                        0 && (snapshot[FirestoreConstants
                                        .GROUP_SIZE] -
                                        groupUsersSnapshot.data
                                            .documents
                                            .length > 0))
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: double.infinity,
                                          child: RaisedButton(
                                            padding: const EdgeInsets.all(
                                              15.0,
                                            ),
                                            onPressed: (snapshot[FirestoreConstants
                                                .GROUP_SIZE] !=
                                                0 &&
                                                (snapshot[FirestoreConstants
                                                    .GROUP_SIZE] -
                                                    groupUsersSnapshot.data
                                                        .documents
                                                        .length <= 0))
                                                ? null
                                                : () async {
                                              await _groupController
                                                  .sendRequest(
                                                snapshot[FirestoreConstants
                                                    .GROUP_NAME],
                                                userData[FirestoreConstants
                                                    .USER_ID],
                                              );
                                            },
                                            child: Text(
                                              (snapshot[FirestoreConstants
                                                  .GROUP_SIZE] !=
                                                  0 &&
                                                  (snapshot[FirestoreConstants
                                                      .GROUP_SIZE] -
                                                      groupUsersSnapshot.data
                                                          .documents
                                                          .length <= 0))
                                                  ? "Group Is Full"
                                                  : "Send request to join the group",
                                              style: GoogleFonts.asap(),),
                                          ),
                                        ),
                                      ),
                                ],
                              );
                            }
                          },
                        );
                      }
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
