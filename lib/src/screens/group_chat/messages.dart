import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_chat/src/screens/group_chat/image_message.dart';
import 'package:group_chat/src/screens/group_chat/message.dart';
import 'package:group_chat/src/screens/group_chat/other_message_widget.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class Messages extends StatelessWidget {
  final String groupName;
  final User user;

  Messages(this.groupName, this.user);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(FirestoreConstants.GROUPS)
          .doc(groupName)
          .collection(FirestoreConstants.MESSAGES)
          .orderBy(
            FirestoreConstants.MESSAGE_ON,
            descending: true,
          )
          .snapshots(),
      builder: (_, messageSnapshot) {
        if (messageSnapshot.connectionState == ConnectionState.waiting) {
          return CenterCircularProgressBar();
        } else if (messageSnapshot.data == null) {
          return CenterText("Not able to get messages");
        } else {
          var snapshot = messageSnapshot.data.documents;
          return ListView.builder(
            padding: const EdgeInsets.only(
              top: 15.0,
            ),
            shrinkWrap: true,
            reverse: true,
            itemCount: snapshot.length,
            itemBuilder: (listContext, position) {
              DocumentSnapshot document = snapshot[position];
              bool isMe =
                  user.uid == document.get(FirestoreConstants.MESSAGE_BY);
              if ((document.data().containsKey(
                  FirestoreConstants.IS_CREATED_MESSAGE) &&
                  document.get(FirestoreConstants.IS_CREATED_MESSAGE)) ||
                  (document.data().containsKey(
                      FirestoreConstants.IS_JOINED_MESSAGE) &&
                      document.get(FirestoreConstants.IS_JOINED_MESSAGE))) {
                return OtherMessageWidget(document);
              } else if (document.data().containsKey(
                  FirestoreConstants.IS_PICTURE_MESSAGE) &&
                  document.get(FirestoreConstants.IS_PICTURE_MESSAGE)) {
                return ImageMessage(isMe, document, mediaQuery.width);
              } else {
                return Message(
                    isMe, document, mediaQuery.width, groupName,
                    user);
              }
            },
          );
        }
      },
    );
  }
}
