import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/util/app_constants.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';

class CreateGroupController extends GetxController {
  var isLoading = false;

  updateLoading() {
    isLoading = !isLoading;
    update();
  }

  void createGroup(groupName, groupDescription) async {
    if (isLoading) return;
    updateLoading();
    await Firestore.instance
        .collection(FirestoreConstants.GROUPS)
        .document(groupName)
        .get()
        .then((groupCheck) {
      if (groupCheck.exists) {
        Utility.showSnackBar(
          "Group Name Already Exists",
          Colors.red,
        );
        updateLoading();
      } else {
        // get current user
        FirebaseAuth.instance.currentUser().then((currentUser) {
          if (currentUser != null) {
            // create group
            Firestore.instance
                .collection(FirestoreConstants.GROUPS)
                .document(groupName)
                .setData({
              FirestoreConstants.GROUP_NAME: groupName,
              FirestoreConstants.GROUP_DESCRIPTION: groupDescription,
              FirestoreConstants.GROUP_SIZE: 100,
              FirestoreConstants.CREATED_BY: currentUser.uid,
              FirestoreConstants.CREATED_ON:
                  DateTime.now().millisecondsSinceEpoch,
              FirestoreConstants.GROUP_PROFILE_IMAGE:
                  AppConstants.DEFAULT_GROUP_PROFILE_IMAGE,
              FirestoreConstants.GROUP_BACKGROUND_IMAGE:
                  AppConstants.DEFAULT_GROUP_PROFILE_BACKGROUND,
            }).then((value) {
              // add the current user to the group
              Firestore.instance
                  .collection(FirestoreConstants.GROUPS)
                  .document(groupName)
                  .collection(FirestoreConstants.USER)
                  .document(currentUser.uid)
                  .setData({
                FirestoreConstants.JOINED_ON:
                    DateTime.now().millisecondsSinceEpoch,
                FirestoreConstants.IS_OWNER: true,
                FirestoreConstants.USER_ID: currentUser.uid,
              }).then((value) {
                // add the group to the current user
                Firestore.instance
                    .collection(FirestoreConstants.USER)
                    .document(currentUser.uid)
                    .collection(FirestoreConstants.GROUPS)
                    .document(groupName)
                    .setData({
                  FirestoreConstants.GROUP_NAME: groupName,
                  FirestoreConstants.GROUP_DESCRIPTION: groupDescription,
                  FirestoreConstants.GROUP_SIZE: 100,
                  FirestoreConstants.CREATED_BY: currentUser.uid,
                  FirestoreConstants.IS_OWNER: true,
                  FirestoreConstants.GROUP_PROFILE_IMAGE:
                      AppConstants.DEFAULT_GROUP_PROFILE_IMAGE,
                  FirestoreConstants.GROUP_BACKGROUND_IMAGE:
                      AppConstants.DEFAULT_GROUP_PROFILE_BACKGROUND,
                }).then((value) {
                  Firestore.instance
                      .collection(FirestoreConstants.GROUPS)
                      .document(groupName)
                      .collection(FirestoreConstants.MESSAGES)
                      .document()
                      .setData({
                    FirestoreConstants.MESSAGE_ON:
                        DateTime.now().millisecondsSinceEpoch,
                    FirestoreConstants.IS_CREATED_MESSAGE: true,
                    FirestoreConstants.MESSAGE: "Group Created"
                  }).then((value) {
                    updateLoading();
                    Get.back(result: groupName);
                  });
                });
              });
            });
          } else {
            updateLoading();
            Utility.showSnackBar(
              "Not able to get current user details.",
              Colors.red,
            );
          }
        });
      }
    });
  }
}
