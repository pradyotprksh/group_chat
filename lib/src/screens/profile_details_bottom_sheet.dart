import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/home/profile/profile_group_details.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';

class ProfileDetailsBottomSheet extends StatelessWidget {
  final DocumentSnapshot snapshot;

  ProfileDetailsBottomSheet(this.snapshot);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        leading: CloseButton(),
        title: Text(
          snapshot[FirestoreConstants.USER_NAME],
          style: GoogleFonts.asap(),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: FutureBuilder(
          future: Firestore.instance
              .collection(FirestoreConstants.USER)
              .document(snapshot[FirestoreConstants.MESSAGE_BY])
              .collection(FirestoreConstants.GROUPS)
              .where(FirestoreConstants.IS_OWNER, isEqualTo: true)
              .getDocuments(),
          builder: (_, groupOwnerSnapshot) {
            if (groupOwnerSnapshot.connectionState == ConnectionState.waiting) {
              return CenterCircularProgressBar();
            }
            var groupOwner = 0;
            if (groupOwnerSnapshot.data != null) {
              groupOwner = groupOwnerSnapshot.data.documents.length;
            }
            return FutureBuilder(
              future: Firestore.instance
                  .collection(FirestoreConstants.USER)
                  .document(snapshot[FirestoreConstants.MESSAGE_BY])
                  .collection(FirestoreConstants.GROUPS)
                  .getDocuments(),
              builder: (_, groupJoinedSnapshot) {
                if (groupJoinedSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CenterCircularProgressBar();
                }
                var groupJoined = 0;
                if (groupJoinedSnapshot.data != null) {
                  groupJoined = groupJoinedSnapshot.data.documents.length;
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      padding: const EdgeInsets.all(
                        15.0,
                      ),
                      child: ClipOval(
                        child: FadeInImage(
                          image: NetworkImage(
                            snapshot[FirestoreConstants.USER_PROFILE_PIC],
                          ),
                          placeholder: AssetImage(
                            "assets/default_profile.png",
                          ),
                        ),
                      ),
                    ),
                    Text(
                      snapshot[FirestoreConstants.USER_NAME],
                      style: GoogleFonts.asap(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    ProfileGroupDetails(groupOwner, groupJoined,
                        snapshot[FirestoreConstants.MESSAGE_BY]),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
