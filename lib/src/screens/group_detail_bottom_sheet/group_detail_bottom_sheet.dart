import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class GroupDetailBottomSheet extends StatelessWidget {
  final String groupName;

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
                  .collection(FirestoreConstants.USER)
                  .document(snapshot[FirestoreConstants.CREATED_BY])
                  .get(),
              builder: (_, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return CenterCircularProgressBar();
                } else if (userSnapshot.data == null) {
                  return CenterText("Not able to get group data.");
                } else {
                  var userData = userSnapshot.data;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        FadeInImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            snapshot[FirestoreConstants.GROUP_BACKGROUND_IMAGE],
                          ),
                          placeholder:
                              AssetImage("assets/default_group_background.jpg"),
                        ),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Container(
                              padding: const EdgeInsets.all(
                                8.0,
                              ),
                              child: Image.network(
                                snapshot[
                                    FirestoreConstants.GROUP_PROFILE_IMAGE],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            snapshot[FirestoreConstants.GROUP_NAME],
                            style: GoogleFonts.asap(fontSize: 18.0),
                          ),
                          subtitle: Text(
                            snapshot[FirestoreConstants.GROUP_DESCRIPTION],
                            style: GoogleFonts.asap(),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          title: Text(
                            "Created On ${Utility.getTimeFromTimeStamp(snapshot[FirestoreConstants.CREATED_ON])}",
                          ),
                          subtitle: Text(
                              "By ${userData[FirestoreConstants.USER_NAME]}"),
                        ),
                      ],
                    ),
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
