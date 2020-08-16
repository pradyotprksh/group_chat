import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/group_list/single_group_detail.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';
import 'package:group_chat/src/widget/shimmer_layout.dart';

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
          (type == "0") ? "Groups Owned" : "Groups Joined",
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
            : Firestore.instance
            .collection(FirestoreConstants.USER)
            .document(userId)
            .collection(FirestoreConstants.GROUPS)
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
                  return FutureBuilder(
                    future: Firestore.instance
                        .document(snapshot[position]
                    [FirestoreConstants.GROUP_REFERENCE]
                        .path)
                        .get(),
                    builder: (_, groupDetailsSnapshot) {
                      if (groupDetailsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return ShimmerLayout();
                      } else if (groupDetailsSnapshot.data == null) {
                        return CenterText("Not able to get group details");
                      } else {
                        return SingleGroupDetail(groupDetailsSnapshot.data);
                      }
                    },
                  );
                },
              );
            } else {
              return CenterText(
                (type == "0")
                    ? "No Groups Created"
                    : "No Groups Joined",
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
