import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/groups_controller.dart';
import 'package:group_chat/src/screens/group_chat/group_chat_screen.dart';
import 'package:group_chat/src/screens/group_detail_bottom_sheet/group_detail_bottom_sheet.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';
import 'package:group_chat/src/util/utility.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class HomePage extends StatelessWidget {
  final GroupController _groupController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: true,
        title: Text(
          StringConstant.APP_NAME,
          style: GoogleFonts.lemonada(
            fontSize: 30,
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
      body: SafeArea(
        top: true,
        child: FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder: (_, currentUserSnapshot) {
            if (currentUserSnapshot.connectionState ==
                ConnectionState.waiting) {
              return CenterCircularProgressBar();
            } else if (currentUserSnapshot.data == null) {
              return CenterText("Not able to get your data. Please try again,");
            } else {
              return StreamBuilder(
                  stream: Firestore.instance
                      .collection(FirestoreConstants.USER)
                      .document(currentUserSnapshot.data.uid)
                      .collection(FirestoreConstants.GROUPS)
                      .snapshots(),
                  builder: (_, groupSnapshot) {
                    if (groupSnapshot.connectionState ==
                        ConnectionState.waiting)
                      return CenterCircularProgressBar();
                    var snapshot = groupSnapshot.data.documents;
                    if (snapshot != null) {
                      if (snapshot.length > 0) {
                        return ListView.builder(
                          padding: const EdgeInsets.only(
                            top: 15,
                          ),
                          itemCount: snapshot.length,
                          itemBuilder: (listContext, position) {
                            return FutureBuilder(
                              future: Firestore.instance
                                  .document(snapshot[position]
                                          [FirestoreConstants.GROUP_REFERENCE]
                                      .path)
                                  .get(),
                              builder: (_, groupDetailsSnapshot) {
                                if (groupDetailsSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Padding(
                                    padding: const EdgeInsets.all(
                                      15.0,
                                    ),
                                    child:
                                        CenterText("Getting group details..."),
                                  );
                                } else if (groupDetailsSnapshot.data == null) {
                                  return CenterText(
                                      "Not able to get group details");
                                } else {
                                  return Column(
                                    children: [
                                      ListTile(
                                        onTap: () async {
                                          Utility.showLoadingDialog(
                                              "Opening Please Wait...");
                                          var isAllowed = await _groupController
                                              .isUserJoinedTheGroup(
                                                  groupDetailsSnapshot.data[
                                                      FirestoreConstants
                                                          .GROUP_NAME]);
                                          if (isAllowed) {
                                            Get.back();
                                            Get.toNamed(
                                                GroupChatScreen.route_name,
                                                arguments:
                                                    groupDetailsSnapshot.data[
                                                        FirestoreConstants
                                                            .GROUP_NAME]);
                                          } else {
                                            Get.back();
                                            Get.bottomSheet(
                                                GroupDetailBottomSheet(
                                                    groupDetailsSnapshot.data[
                                                        FirestoreConstants
                                                            .GROUP_NAME]));
                                            Utility.showSnackBar(
                                                "You are not a member of this group. To chat in this group please send a request first",
                                                Colors.red);
                                          }
                                        },
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Container(
                                            padding: const EdgeInsets.all(
                                              8.0,
                                            ),
                                            child: Image.network(
                                              groupDetailsSnapshot.data[
                                                  FirestoreConstants
                                                      .GROUP_PROFILE_IMAGE],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          groupDetailsSnapshot.data[
                                              FirestoreConstants.GROUP_NAME],
                                          style:
                                              GoogleFonts.asap(fontSize: 18.0),
                                        ),
                                        trailing:
                                            Icon(Icons.chat_bubble_outline),
                                      ),
                                      Divider(
                                        thickness: 1,
                                      ),
                                    ],
                                  );
                                }
                              },
                            );
                          },
                        );
                      } else {
                        return CenterText(
                          "No Groups Joined",
                        );
                      }
                    } else {
                      return CenterText(
                          "Something Went Wrong while getting groups.");
                    }
                  });
            }
          },
        ),
      ),
    );
  }
}
