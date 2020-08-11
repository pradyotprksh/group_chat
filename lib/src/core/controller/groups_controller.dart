import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/util/app_constants.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';

class GroupController extends GetxController {
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
            DocumentReference documentReference = Firestore.instance
                .collection(FirestoreConstants.GROUPS)
                .document(groupName);
            documentReference.setData({
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
                  FirestoreConstants.IS_OWNER: true,
                  FirestoreConstants.GROUP_REFERENCE: documentReference,
                  FirestoreConstants.GROUP_NAME: groupName,
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
                    FirestoreConstants.MESSAGE_BY: currentUser.uid,
                    FirestoreConstants.MESSAGE:
                        "${currentUser.displayName} created the group",
                    FirestoreConstants.USER_NAME: "${currentUser.displayName}",
                    FirestoreConstants.USER_PROFILE_PIC:
                        "${currentUser.photoUrl}",
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

  Future<bool> isUserJoinedTheGroup(String groupName) async {
    var isAllowed = false;
    var currentUser = await FirebaseAuth.instance.currentUser();
    var groupDetails = await Firestore.instance
        .collection(FirestoreConstants.USER)
        .document(currentUser.uid)
        .collection(FirestoreConstants.GROUPS)
        .document(groupName)
        .get();
    if (groupDetails.exists) {
      isAllowed = true;
    } else {
      isAllowed = false;
    }
    return isAllowed;
  }

  Future<void> sendRequest(groupName, inviteBy) async {
    try {
      Utility.showLoadingDialog("Sending request. Please wait...");
      var firebaseUser = await FirebaseAuth.instance.currentUser();
      var checkInvite = await Firestore.instance
          .collection(FirestoreConstants.GROUPS)
          .document(groupName)
          .collection(FirestoreConstants.GROUPS_INVITE)
          .document("${firebaseUser.uid}$groupName$inviteBy")
          .get();
      if (checkInvite.exists) {
        Get.back();
        Utility.showSnackBar(
            "Invitation already send. Waiting for confirmation.", Colors.red);
        return;
      } else {
        var documentReference = Firestore.instance
            .collection(FirestoreConstants.GROUPS)
            .document(groupName)
            .collection(FirestoreConstants.GROUPS_INVITE)
            .document("${firebaseUser.uid}$groupName$inviteBy");
        await documentReference.setData({
          FirestoreConstants.GROUP_NAME: groupName,
          FirestoreConstants.GROUP_INVITE_TO: inviteBy,
          FirestoreConstants.GROUP_INVITE_BY: firebaseUser.uid,
          FirestoreConstants.USER_NAME: firebaseUser.displayName,
          FirestoreConstants.USER_PROFILE_PIC: firebaseUser.photoUrl,
          FirestoreConstants.INVITE_ON: DateTime
              .now()
              .millisecondsSinceEpoch,
          FirestoreConstants.GROUP_INVITE_ACCEPTED: false,
          FirestoreConstants.IS_REJECTED: false,
        });
        await Firestore.instance.collection(FirestoreConstants.USER).document(
            firebaseUser.uid)
            .collection(FirestoreConstants.GROUPS_INVITE)
            .document().setData({
          FirestoreConstants.INVITE_ID: documentReference,
          FirestoreConstants.INVITE_ON: DateTime
              .now()
              .millisecondsSinceEpoch,
        });
        await Firestore.instance.collection(FirestoreConstants.USER).document(
            inviteBy)
            .collection(FirestoreConstants.GROUPS_INVITE)
            .document().setData({
          FirestoreConstants.INVITE_ID: documentReference,
          FirestoreConstants.INVITE_ON: DateTime
              .now()
              .millisecondsSinceEpoch,
        });
        Get.back();
        Utility.showSnackBar(
            "Invitation sent to the group owner", Colors.green);
        return;
      }
    } catch (error) {
      Get.back();
      Utility.showSnackBar(error.toString(), Colors.red);
      return;
    }
  }

  // 1 = Accepted 2 = Rejected 3 = Send Again
  Future<void> updateInviteStatus(DocumentSnapshot inviteDetails,
      int type) async {
    Utility.showLoadingDialog("Please wait while we update the invite status");
    await Firestore.instance
        .collection(FirestoreConstants.GROUPS)
        .document(inviteDetails[FirestoreConstants.GROUP_NAME])
        .collection(FirestoreConstants.GROUPS_INVITE)
        .document(inviteDetails.documentID).updateData({
      FirestoreConstants.GROUP_INVITE_ACCEPTED: type == 1,
      FirestoreConstants.IS_REJECTED: type == 2,
    });

    if (type == 3) {
      return;
    }

    // check if user is already in the group
    var documents = await Firestore.instance
        .collection(FirestoreConstants.USER)
        .document(inviteDetails[FirestoreConstants.GROUP_INVITE_BY])
        .collection(FirestoreConstants.GROUPS)
        .where(FirestoreConstants.GROUP_NAME,
        isEqualTo: inviteDetails[FirestoreConstants.GROUP_NAME])
        .getDocuments();
    if (documents.documents.length == 0) {
      DocumentReference documentReference = Firestore.instance
          .collection(FirestoreConstants.GROUPS)
          .document(inviteDetails[FirestoreConstants.GROUP_NAME]);
      await documentReference
          .collection(FirestoreConstants.USER)
          .document(inviteDetails[FirestoreConstants.GROUP_INVITE_BY])
          .setData({
        FirestoreConstants.JOINED_ON: DateTime
            .now()
            .millisecondsSinceEpoch,
        FirestoreConstants.IS_OWNER: false,
        FirestoreConstants.USER_ID: inviteDetails[FirestoreConstants
            .GROUP_INVITE_BY],
      });
      await Firestore.instance
          .collection(FirestoreConstants.USER)
          .document(inviteDetails[FirestoreConstants.GROUP_INVITE_BY])
          .collection(FirestoreConstants.GROUPS)
          .document(inviteDetails[FirestoreConstants.GROUP_NAME])
          .setData({
        FirestoreConstants.IS_OWNER: false,
        FirestoreConstants.GROUP_NAME: inviteDetails[FirestoreConstants
            .GROUP_NAME],
        FirestoreConstants.GROUP_REFERENCE:
        documentReference
      });
      await Firestore.instance
          .collection(FirestoreConstants.GROUPS)
          .document(inviteDetails[FirestoreConstants.GROUP_NAME])
          .collection(FirestoreConstants.MESSAGES)
          .document()
          .setData({
        FirestoreConstants.MESSAGE_ON:
        DateTime
            .now()
            .millisecondsSinceEpoch,
        FirestoreConstants.IS_JOINED_MESSAGE: true,
        FirestoreConstants.MESSAGE_BY: inviteDetails[FirestoreConstants
            .GROUP_INVITE_BY],
        FirestoreConstants.MESSAGE: "${inviteDetails[FirestoreConstants
            .USER_NAME]} joined the group",
        FirestoreConstants.USER_NAME: "${inviteDetails[FirestoreConstants
            .USER_NAME]}",
        FirestoreConstants.USER_PROFILE_PIC: "${inviteDetails[FirestoreConstants
            .USER_PROFILE_PIC]}",
      });
    }
  }
}
