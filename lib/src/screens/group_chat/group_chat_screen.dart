import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/screens/group_chat/messages.dart';
import 'package:group_chat/src/screens/group_chat/new_message.dart';

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
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Messages(Get.arguments, FirebaseAuth.instance.currentUser),
            ),
            NewMessage(Get.arguments, FirebaseAuth.instance.currentUser),
          ],
        ),
      ),
    );
  }
}
