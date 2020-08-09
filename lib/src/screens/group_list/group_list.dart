import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/group_list/single_group_detail.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class GroupList extends StatelessWidget {
  static const route_name = "group_list";
  final String userId = Get.parameters["userId"];
  final String type = Get.parameters["type"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          (type == "0")
              ? "Groups Owned"
              : (type == "1") ? "Groups Joined" : "Groups Invite",
          style: GoogleFonts.asap(),
        ),
      ),
      body: StreamBuilder(
        stream: (type == "0")
            ? Firestore.instance
                .collection(FirestoreConstants.USER)
                .document(userId)
                .collection(FirestoreConstants.GROUPS)
                .where(FirestoreConstants.IS_OWNER, isEqualTo: true)
                .snapshots()
            : (type == "1")
                ? Firestore.instance
                    .collection(FirestoreConstants.USER)
                    .document(userId)
                    .collection(FirestoreConstants.GROUPS)
                    .snapshots()
                : Firestore.instance
                    .collection(FirestoreConstants.USER)
                    .document(userId)
                    .collection(FirestoreConstants.GROUPS_INVITE)
                    .snapshots(),
        builder: (_, groupSnapshot) {
          if (groupSnapshot.connectionState == ConnectionState.waiting)
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
                  return SingleGroupDetail(snapshot[position]);
                },
              );
            } else {
              return CenterText(
                (type == "0")
                    ? "No Groups Created"
                    : (type == "1")
                        ? "No Groups Joined"
                        : "No Invitation Pending",
              );
            }
          } else {
            return CenterText("Something Went Wrong while getting groups.");
          }
        },
      ),
    );
  }
}
