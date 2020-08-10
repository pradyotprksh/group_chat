import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/screens/group_chat/messages.dart';
import 'package:group_chat/src/screens/group_chat/new_message.dart';
import 'package:group_chat/src/widget/center_text.dart';

class GroupChatScreen extends StatelessWidget {
  static const route_name = "group_chat_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(Get.arguments),
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (_, currentUserSnapshot) {
          if (currentUserSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (currentUserSnapshot.data == null) {
            return CenterText("Not able to get messages");
          } else {
            return Container(
              child: Column(
                children: [
                  Expanded(
                    child:
                        Messages(Get.arguments, currentUserSnapshot.data.uid),
                  ),
                  NewMessage(Get.arguments, currentUserSnapshot.data),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
