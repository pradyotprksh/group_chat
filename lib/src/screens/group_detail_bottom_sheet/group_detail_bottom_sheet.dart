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
  final bool allowClickAction;
  final GroupController _groupController = Get.find();

  GroupDetailBottomSheet(this.groupName, this.allowClickAction);

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
        future: FirebaseFirestore.instance
            .collection(FirestoreConstants.GROUPS)
            .doc(groupName)
            .get(),
        builder: (_, groupSnapshot) {
          if (groupSnapshot.connectionState == ConnectionState.waiting) {
            return CenterCircularProgressBar();
          } else if (groupSnapshot.data == null) {
            return CenterText("Not able to get group data.");
          } else {
            var snapshot = groupSnapshot.data;
            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection(FirestoreConstants.GROUPS)
                  .doc(groupName)
                  .collection(FirestoreConstants.USER)
                  .get(),
              builder: (_, groupUsersSnapshot) {
                if (groupUsersSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CenterCircularProgressBar();
                } else if (groupSnapshot.data == null) {
                  return CenterText("Not able to get group data.");
                } else {
                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection(FirestoreConstants.USER)
                        .doc(snapshot.get(FirestoreConstants.CREATED_BY))
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
                              snapshot.get(FirestoreConstants.GROUP_NAME)),
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
                                            snapshot.get(FirestoreConstants
                                                .GROUP_BACKGROUND_IMAGE),
                                          ),
                                          placeholder: AssetImage(
                                              "assets/default_group_background.jpg"),
                                        ),
                                        Tooltip(
                                          message: "Go To Group",
                                          child: ListTile(
                                            onTap: allowClickAction ? () async {
                                              Utility.showLoadingDialog(
                                                  "Opening Please Wait...");
                                              var isAllowed = await _groupController
                                                  .isUserJoinedTheGroup(snapshot
                                                  .get(FirestoreConstants
                                                  .GROUP_NAME));
                                              if (isAllowed) {
                                                Get.back();
                                                Get.toNamed(
                                                    GroupChatScreen.route_name,
                                                    arguments: snapshot.get(
                                                        FirestoreConstants
                                                            .GROUP_NAME));
                                              } else {
                                                Get.back();
                                                Utility.showSnackBar(
                                                    "You are not a member of this group. To chat in this group please send a request first",
                                                    Colors.red);
                                              }
                                            } : null,
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Image.network(
                                                  snapshot.get(
                                                      FirestoreConstants
                                                          .GROUP_PROFILE_IMAGE),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            trailing: allowClickAction ? Icon(
                                              Icons.arrow_right,
                                              color: Colors.white,
                                            ) : null,
                                            title: Text(
                                              snapshot.get(FirestoreConstants
                                                  .GROUP_NAME),
                                              style: GoogleFonts.asap(
                                                  fontSize: 18.0),
                                            ),
                                            subtitle: Text(
                                              snapshot.get(FirestoreConstants
                                                  .GROUP_DESCRIPTION),
                                              style: GoogleFonts.asap(),
                                            ),
                                          ),
                                        ),
                                        Divider(),
                                        ListTile(
                                          title: Text(
                                            "Created On ${Utility
                                                .getTimeFromTimeStamp(
                                                snapshot.get(FirestoreConstants
                                                    .CREATED_ON))}",
                                          ),
                                          subtitle: Text(
                                              "By ${userData.get(
                                                  FirestoreConstants
                                                      .USER_NAME)}"),
                                        ),
                                        ListTile(
                                          title: Text(
                                            "${groupUsersSnapshot.data.documents
                                                .length} users has joined the group",
                                          ),
                                          subtitle: Text(
                                              snapshot.get(FirestoreConstants
                                                  .GROUP_SIZE) ==
                                                  0
                                                  ? ""
                                                  : "${snapshot.get(
                                                  FirestoreConstants
                                                      .GROUP_SIZE) -
                                                  groupUsersSnapshot.data
                                                      .documents
                                                      .length} space left"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!groupJoinedSnapshot.data)
                                    if (snapshot.get(FirestoreConstants
                                        .GROUP_SIZE) !=
                                        0 && (snapshot.get(FirestoreConstants
                                        .GROUP_SIZE) -
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
                                            onPressed: (snapshot.get(
                                                FirestoreConstants
                                                    .GROUP_SIZE) !=
                                                0 &&
                                                (snapshot.get(FirestoreConstants
                                                    .GROUP_SIZE) -
                                                    groupUsersSnapshot.data
                                                        .documents
                                                        .length <= 0))
                                                ? null
                                                : () async {
                                              await _groupController
                                                  .sendRequest(
                                                snapshot.get(FirestoreConstants
                                                    .GROUP_NAME),
                                                userData.get(FirestoreConstants
                                                    .USER_ID),
                                              );
                                            },
                                            child: Text(
                                              (snapshot.get(FirestoreConstants
                                                  .GROUP_SIZE) !=
                                                  0 &&
                                                  (snapshot.get(
                                                      FirestoreConstants
                                                          .GROUP_SIZE) -
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
