import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/home_controller.dart';
import 'package:group_chat/src/screens/group_list/single_group_detail.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class AllGroupLists extends StatelessWidget {
  final HomeController _homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 15.0,
              right: 15.0,
              top: 15.0,
            ),
            child: RaisedButton(
              color: Colors.blue[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20.0,
                ),
              ),
              onPressed: () {
                _homeController.updateCurrentIndex(1);
              },
              child: Text(
                "Search",
                style: GoogleFonts.asap(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(FirestoreConstants.GROUPS)
                  .orderBy(
                    FirestoreConstants.GROUP_NAME,
                  )
                  .snapshots(),
              builder: (_, groupsSnapshot) {
                if (groupsSnapshot.connectionState == ConnectionState.waiting) {
                  return CenterCircularProgressBar();
                } else if (groupsSnapshot.data == null) {
                  return CenterText(
                      "No groups created yet. Be the first to create one by clicking here.");
                } else {
                  var snapshot = groupsSnapshot.data.documents;
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.length,
                      padding: const EdgeInsets.only(
                        top: 15.0,
                      ),
                      itemBuilder: (_, position) {
                        return SingleGroupDetail(snapshot[position]);
                      });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
