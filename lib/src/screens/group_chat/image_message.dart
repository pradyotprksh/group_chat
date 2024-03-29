import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/screens/group_chat/circle_profile_image.dart';
import 'package:group_chat/src/screens/image_preview_screen.dart';
import 'package:group_chat/src/screens/profile_details_bottom_sheet.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';
import 'package:menu/menu.dart';

class ImageMessage extends StatelessWidget {
  final bool isMe;
  final DocumentSnapshot snapshot;
  final double width;

  ImageMessage(this.isMe, this.snapshot, this.width);

  @override
  Widget build(BuildContext context) {
    return Menu(
      items: [
        if (isMe)
          MenuItem("Delete", () async {
            Utility.showNotDismissibleSnackBar("Deleting Image...");
            try {
              var imageReference = await FirebaseStorage.instance
                  .getReferenceFromUrl(
                      snapshot.get(FirestoreConstants.MESSAGE));
              await imageReference.delete();
              await FirebaseFirestore.instance
                  .doc(snapshot.reference.path)
                  .delete();
            } catch (error) {
              Utility.showSnackBar(error.toString(), Colors.red);
            }
            Get.back();
          }),
        if (!isMe) MenuItem("Report", () {
          Utility.showSnackBar("Coming Soon!!", Colors.green);
        }),
        MenuItem("Copy", () {
          ClipboardManager.copyToClipBoard(
              snapshot.get(FirestoreConstants.MESSAGE))
              .then((value) => Utility.showSnackBar("Copied", Colors.green));
        }),
      ],
      child: GestureDetector(
        onTap: () {
          Get.toNamed(
            ImagePreviewScreen.route_name,
            arguments: snapshot.get(FirestoreConstants.MESSAGE),
          );
        },
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
                    snapshot.get(FirestoreConstants.USER_PROFILE_PIC),
                  ),
                ),
              const SizedBox(
                width: 15,
              ),
              Container(
                decoration: BoxDecoration(
                  color:
                  isMe ? Colors.grey[300] : Theme
                      .of(context)
                      .primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft:
                    !isMe ? Radius.circular(0) : Radius.circular(12),
                    bottomRight:
                    !isMe ? Radius.circular(12) : Radius.circular(0),
                  ),
                ),
                padding: const EdgeInsets.all(
                  5.0,
                ),
                constraints: BoxConstraints(
                  maxWidth: (width / 2) - 10,
                  maxHeight: 200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft:
                    !isMe ? Radius.circular(0) : Radius.circular(12),
                    bottomRight:
                    !isMe ? Radius.circular(12) : Radius.circular(0),
                  ),
                  child: Image.network(
                    snapshot.get(FirestoreConstants.MESSAGE),
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              if (isMe)
                CircleProfileImage(
                  snapshot.get(FirestoreConstants.USER_PROFILE_PIC),
                ),
              if (isMe)
                const SizedBox(
                  width: 15,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
