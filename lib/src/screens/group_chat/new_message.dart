import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class NewMessage extends StatelessWidget {
  final String groupName;
  final User user;
  final picker = ImagePicker();

  NewMessage(this.groupName, this.user);

  @override
  Widget build(BuildContext context) {
    var _enteredMessage = "";
    final _controller = TextEditingController();

    Future getImage() async {
      final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 40,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (file != null) {
          Utility.showNotDismissibleSnackBar("Sending Image...");
          var randomNumber = randomBetween(
            10,
            40,
          );
          try {
            var fileName = randomAlphaNumeric(randomNumber);
            StorageReference storageReference = FirebaseStorage.instance
                .ref()
                .child("group_images/$groupName/${user.uid}/$fileName");
            final StorageUploadTask uploadTask = storageReference.putFile(file);
            final StorageTaskSnapshot downloadUrl =
                (await uploadTask.onComplete);
            final String url = await downloadUrl.ref.getDownloadURL();
            await FirebaseFirestore.instance
                .collection(FirestoreConstants.GROUPS)
                .doc(groupName)
                .collection(FirestoreConstants.MESSAGES)
                .doc()
                .set({
              FirestoreConstants.MESSAGE_ON:
                  DateTime.now().millisecondsSinceEpoch,
              FirestoreConstants.MESSAGE_BY: user.uid,
              FirestoreConstants.MESSAGE: url,
              FirestoreConstants.IS_PICTURE_MESSAGE: true,
              FirestoreConstants.USER_NAME: "${user.displayName}",
              FirestoreConstants.USER_PROFILE_PIC: "${user.photoURL}",
              FirestoreConstants.IMAGE_PATH: storageReference.path,
            });
          } catch (error) {
            Utility.showSnackBar(error.toString(), Colors.red);
          }
          Get.back();
        }
      }
    }

    void _sendMessage() {
      if (_enteredMessage.trim().isNotEmpty) {
        _controller.clear();
        FirebaseFirestore.instance
            .collection(FirestoreConstants.GROUPS)
            .doc(groupName)
            .collection(FirestoreConstants.MESSAGES)
            .doc()
            .set({
          FirestoreConstants.MESSAGE_ON: DateTime
              .now()
              .millisecondsSinceEpoch,
          FirestoreConstants.MESSAGE_BY: user.uid,
          FirestoreConstants.MESSAGE: _enteredMessage,
          FirestoreConstants.USER_NAME: "${user.displayName}",
          FirestoreConstants.USER_PROFILE_PIC: "${user.photoURL}",
        }).then((value) {
          _enteredMessage = "";
        });
      }
    }

    return Container(
      padding: EdgeInsets.all(
        10,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _controller,
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                hintText: 'Remember to keep group chat respectful...',
                labelText: 'Type Message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                ),
                suffixIcon: IconButton(
                  color: Theme
                      .of(context)
                      .accentColor,
                  icon: Icon(
                    Icons.send,
                  ),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
                prefixIcon: IconButton(
                  color: Theme
                      .of(context)
                      .accentColor,
                  icon: Icon(
                    Icons.image,
                  ),
                  onPressed: getImage,
                ),
              ),
              onChanged: (value) {
                _enteredMessage = value;
              },
              onSubmitted: (value) {
                if (_enteredMessage.trim().isNotEmpty) {
                  _sendMessage();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
