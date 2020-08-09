import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            // get current user groups
            Firestore.instance
                .collection(FirestoreConstants.GROUPS)
                .where(FirestoreConstants.CREATED_BY,
                    isEqualTo: currentUser.uid)
                .getDocuments()
                .then((currentUserGroups) {
              if (currentUserGroups.documents.length > 3) {
                Utility.showSnackBar(
                  "You have exceeded your group owner count. Please delete some of the groups to create new.",
                  Colors.red,
                );
                updateLoading();
              } else {
                // create group
                Firestore.instance
                    .collection(FirestoreConstants.GROUPS)
                    .document(groupName)
                    .setData({
                  FirestoreConstants.GROUP_NAME: groupName,
                  FirestoreConstants.GROUP_DESCRIPTION: groupDescription,
                  FirestoreConstants.GROUP_SIZE: 100,
                  FirestoreConstants.CREATED_BY: currentUser.uid,
                  FirestoreConstants.CURRENT_GROUP_SIZE: 1,
                  FirestoreConstants.CREATED_ON:
                      DateTime.now().millisecondsSinceEpoch,
                  FirestoreConstants.GROUP_PROFILE_IMAGE:
                      "https://image.flaticon.com/icons/png/512/16/16016.png",
                  FirestoreConstants.GROUP_BACKGROUND_IMAGE:
                      "https://images.unsplash.com/photo-1506869640319-fe1a24fd76dc?ixlib=rb-1.2.1&auto=format&fit=crop&w=2550&q=80",
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
                      "https://image.flaticon.com/icons/png/512/16/16016.png",
                      FirestoreConstants.GROUP_BACKGROUND_IMAGE:
                      "https://images.unsplash.com/photo-1506869640319-fe1a24fd76dc?ixlib=rb-1.2.1&auto=format&fit=crop&w=2550&q=80",
                    }).then((value) {
                      updateLoading();
                      Get.back(result: groupName);
                    });
                  });
                });
              }
            }).catchError((error) {
              Utility.showSnackBar(
                "Not able to create group at the moment.",
                Colors.red,
              );
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
