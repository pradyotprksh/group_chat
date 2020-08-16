import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/group_chat/circle_profile_image.dart';
import 'package:group_chat/src/screens/profile_details_bottom_sheet.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';
import 'package:menu/menu.dart';
import 'package:url_launcher/url_launcher.dart';

class Message extends StatelessWidget {
  final bool isMe;
  final DocumentSnapshot snapshot;
  final double screenWidth;
  final String groupName;
  final FirebaseUser user;

  Message(
      this.isMe, this.snapshot, this.screenWidth, this.groupName, this.user);

  @override
  Widget build(BuildContext context) {
    var _editMessageValue = "";
    var _replyMessageValue = "";

    void _editMessage() {
      if (_editMessageValue.trim() == "") {
        return;
      }
      Firestore.instance.document(snapshot.reference.path).updateData({
        FirestoreConstants.MESSAGE: _editMessageValue,
      }).then((value) => _editMessageValue = "");
    }

    void _replyMessage() {
      if (_replyMessageValue.trim() == "") {
        return;
      }
      Firestore.instance
          .collection(FirestoreConstants.GROUPS)
          .document(groupName)
          .collection(FirestoreConstants.MESSAGES)
          .document()
          .setData({
        FirestoreConstants.MESSAGE_ON: DateTime.now().millisecondsSinceEpoch,
        FirestoreConstants.IS_REPLY_MESSAGE: true,
        FirestoreConstants.REPLY_FOR: snapshot[FirestoreConstants.MESSAGE],
        FirestoreConstants.MESSAGE_BY: user.uid,
        FirestoreConstants.MESSAGE: _replyMessageValue,
        FirestoreConstants.USER_NAME: "${user.displayName}",
        FirestoreConstants.USER_PROFILE_PIC: "${user.photoUrl}",
      }).then((value) {
        _replyMessageValue = "";
      });
    }

    return Menu(
      items: [
        if (isMe)
          MenuItem(
            "Delete",
            () async {
              try {
                await Firestore.instance
                    .document(snapshot.reference.path)
                    .delete();
              } catch (error) {
                Utility.showSnackBar(error.toString(), Colors.red);
              }
            },
          ),
        MenuItem(
          "Reply",
          () {
            Get.bottomSheet(
              Container(
                padding: const EdgeInsets.all(
                  15.0,
                ),
                color: Colors.black,
                child: TextField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  textInputAction: TextInputAction.done,
                  style: Theme.of(context).textTheme.bodyText1,
                  decoration: InputDecoration(
                    labelText:
                        'Replying for "${snapshot[FirestoreConstants.MESSAGE]}"...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        25.0,
                      ),
                    ),
                    suffixIcon: IconButton(
                      color: Theme.of(context).accentColor,
                      icon: Icon(
                        Icons.done,
                      ),
                      onPressed: () {
                        _replyMessage();
                        Get.back();
                      },
                    ),
                  ),
                  onChanged: (value) {
                    _replyMessageValue = value;
                  },
                  onSubmitted: (value) {
                    _replyMessageValue = value;
                    _replyMessage();
                    Get.back();
                  },
                ),
              ),
            );
          },
        ),
        if (!isMe)
          MenuItem(
            "Report",
            () {
              Utility.showSnackBar("Coming Soon!!", Colors.green);
            },
          ),
        MenuItem(
          "Copy",
          () {
            ClipboardManager.copyToClipBoard(
                    snapshot[FirestoreConstants.MESSAGE])
                .then((value) => Utility.showSnackBar("Copied", Colors.green));
          },
        ),
        if (isMe)
          MenuItem(
            "Edit",
            () {
              Get.bottomSheet(
                Container(
                  padding: const EdgeInsets.all(
                    15.0,
                  ),
                  color: Colors.black,
                  child: TextField(
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    textInputAction: TextInputAction.done,
                    style: Theme.of(context).textTheme.bodyText1,
                    decoration: InputDecoration(
                      labelText: 'Edit Message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          25.0,
                        ),
                      ),
                      suffixIcon: IconButton(
                        color: Theme.of(context).accentColor,
                        icon: Icon(
                          Icons.done,
                        ),
                        onPressed: () {
                          _editMessage();
                          Get.back();
                        },
                      ),
                    ),
                    onChanged: (value) {
                      _editMessageValue = value;
                    },
                    onSubmitted: (value) {
                      _editMessageValue = value;
                      _editMessage();
                      Get.back();
                    },
                  ),
                ),
              );
            },
          ),
      ],
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 15.0,
        ),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe)
              const SizedBox(
                width: 15,
              ),
            if (!isMe)
              GestureDetector(
                onTap: () {
                  Get.bottomSheet(
                    ProfileDetailsBottomSheet(snapshot),
                  );
                },
                child: CircleProfileImage(
                  snapshot[FirestoreConstants.USER_PROFILE_PIC],
                ),
              ),
            const SizedBox(
              width: 15,
            ),
            Container(
              decoration: BoxDecoration(
                color: isMe ? Colors.grey[300] : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomRight: !isMe ? Radius.circular(12) : Radius.circular(0),
                ),
              ),
              constraints: BoxConstraints(
                maxWidth: (screenWidth / 2) - 10,
              ),
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              child: Column(
                crossAxisAlignment:
                    (snapshot[FirestoreConstants.IS_REPLY_MESSAGE] != null &&
                            snapshot[FirestoreConstants.IS_REPLY_MESSAGE])
                        ? CrossAxisAlignment.stretch
                        : CrossAxisAlignment.center,
                children: [
                  if (snapshot[FirestoreConstants.IS_REPLY_MESSAGE] != null &&
                      snapshot[FirestoreConstants.IS_REPLY_MESSAGE])
                    Text(
                      "Replied for \"${snapshot[FirestoreConstants.REPLY_FOR]}\"",
                      style: GoogleFonts.asap(
                        color: isMe ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: isMe ? TextAlign.end : TextAlign.start,
                    ),
                  if (snapshot[FirestoreConstants.IS_REPLY_MESSAGE] != null &&
                      snapshot[FirestoreConstants.IS_REPLY_MESSAGE])
                    const SizedBox(
                      height: 5,
                    ),
                  Linkify(
                    onOpen: (link) async {
                      if (await canLaunch(link.url)) {
                        await launch(link.url);
                      } else {
                        Utility.showSnackBar(
                            "Seems like the link is broken.", Colors.red);
                      }
                    },
                    text: "${snapshot[FirestoreConstants.MESSAGE]}",
                    style: GoogleFonts.asap(
                        color: isMe ? Colors.black : Colors.white),
                    linkStyle: GoogleFonts.asap(
                      color: isMe ? Colors.indigoAccent : Colors.white,
                    ),
                    options: LinkifyOptions(
                      humanize: false,
                    ),
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            if (isMe)
              CircleProfileImage(
                snapshot[FirestoreConstants.USER_PROFILE_PIC],
              ),
            if (isMe)
              const SizedBox(
                width: 15,
              ),
          ],
        ),
      ),
    );
  }
}
