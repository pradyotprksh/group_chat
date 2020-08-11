import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_chat/src/screens/group_chat/message.dart';
import 'package:group_chat/src/screens/group_chat/other_message_widget.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class Messages extends StatelessWidget {
  final String groupName;
  final String userId;

  Messages(this.groupName, this.userId);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: Firestore.instance
          .collection(FirestoreConstants.GROUPS)
          .document(groupName)
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
              if ((snapshot[position][FirestoreConstants.IS_CREATED_MESSAGE] !=
                          null &&
                      snapshot[position]
                          [FirestoreConstants.IS_CREATED_MESSAGE]) ||
                  (snapshot[position][FirestoreConstants.IS_JOINED_MESSAGE] !=
                          null &&
                      snapshot[position]
                          [FirestoreConstants.IS_JOINED_MESSAGE])) {
                return OtherMessageWidget(snapshot[position]);
              } else {
                bool isMe =
                    userId == snapshot[position][FirestoreConstants.MESSAGE_BY];
                return Message(isMe, snapshot[position], mediaQuery.width);
              }
            },
          );
        }
      },
    );
  }
}