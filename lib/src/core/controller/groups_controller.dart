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
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.GROUPS)
        .doc(groupName)
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
        User currentUser = FirebaseAuth.instance.currentUser;
        DocumentReference documentReference = FirebaseFirestore.instance
            .collection(FirestoreConstants.GROUPS)
            .doc(groupName);
        documentReference.set({
          FirestoreConstants.GROUP_NAME: groupName,
          FirestoreConstants.GROUP_DESCRIPTION: groupDescription,
          FirestoreConstants.GROUP_SIZE: 100,
          FirestoreConstants.CREATED_BY: currentUser.uid,
          FirestoreConstants.CREATED_ON: DateTime.now().millisecondsSinceEpoch,
          FirestoreConstants.GROUP_PROFILE_IMAGE:
              AppConstants.DEFAULT_GROUP_PROFILE_IMAGE,
          FirestoreConstants.GROUP_BACKGROUND_IMAGE:
              AppConstants.DEFAULT_GROUP_PROFILE_BACKGROUND,
        }).then((value) {
          // add the current user to the group
          FirebaseFirestore.instance
              .collection(FirestoreConstants.GROUPS)
              .doc(groupName)
              .collection(FirestoreConstants.USER)
              .doc(currentUser.uid)
              .set({
            FirestoreConstants.JOINED_ON: DateTime.now().millisecondsSinceEpoch,
            FirestoreConstants.IS_OWNER: true,
            FirestoreConstants.USER_ID: currentUser.uid,
          }).then((value) {
            // add the group to the current user
            FirebaseFirestore.instance
                .collection(FirestoreConstants.USER)
                .doc(currentUser.uid)
                .collection(FirestoreConstants.GROUPS)
                .doc(groupName)
                .set({
              FirestoreConstants.IS_OWNER: true,
              FirestoreConstants.GROUP_REFERENCE: documentReference,
              FirestoreConstants.GROUP_NAME: groupName,
            }).then((value) {
              FirebaseFirestore.instance
                  .collection(FirestoreConstants.GROUPS)
                  .doc(groupName)
                  .collection(FirestoreConstants.MESSAGES)
                  .doc()
                  .set({
                FirestoreConstants.MESSAGE_ON:
                    DateTime.now().millisecondsSinceEpoch,
                FirestoreConstants.IS_CREATED_MESSAGE: true,
                FirestoreConstants.MESSAGE_BY: currentUser.uid,
                FirestoreConstants.MESSAGE:
                    "${currentUser.displayName} created the group",
                FirestoreConstants.USER_NAME: "${currentUser.displayName}",
                FirestoreConstants.USER_PROFILE_PIC: "${currentUser.photoURL}",
              }).then((value) {
                updateLoading();
                Get.back(result: groupName);
              });
            });
          });
        });
      }
    });
  }

  Future<bool> isUserJoinedTheGroup(String groupName) async {
    var isAllowed = false;
    var currentUser = FirebaseAuth.instance.currentUser;
    var groupDetails = await FirebaseFirestore.instance
        .collection(FirestoreConstants.USER)
        .doc(currentUser.uid)
        .collection(FirestoreConstants.GROUPS)
        .doc(groupName)
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
      var firebaseUser = FirebaseAuth.instance.currentUser;
      var checkInvite = await FirebaseFirestore.instance
          .collection(FirestoreConstants.GROUPS)
          .doc(groupName)
          .collection(FirestoreConstants.GROUPS_INVITE)
          .doc("${firebaseUser.uid}$groupName$inviteBy")
          .get();
      if (checkInvite.exists) {
        Get.back();
        Utility.showSnackBar(
            "Invitation already send. Waiting for confirmation.", Colors.red);
        return;
      } else {
        var documentReference = FirebaseFirestore.instance
            .collection(FirestoreConstants.GROUPS)
            .doc(groupName)
            .collection(FirestoreConstants.GROUPS_INVITE)
            .doc("${firebaseUser.uid}$groupName$inviteBy");
        await documentReference.set({
          FirestoreConstants.GROUP_NAME: groupName,
          FirestoreConstants.GROUP_INVITE_TO: inviteBy,
          FirestoreConstants.GROUP_INVITE_BY: firebaseUser.uid,
          FirestoreConstants.USER_NAME: firebaseUser.displayName,
          FirestoreConstants.USER_PROFILE_PIC: firebaseUser.photoURL,
          FirestoreConstants.INVITE_ON: DateTime
              .now()
              .millisecondsSinceEpoch,
          FirestoreConstants.GROUP_INVITE_ACCEPTED: false,
          FirestoreConstants.IS_REJECTED: false,
        });
        await FirebaseFirestore.instance.collection(FirestoreConstants.USER)
            .doc(
            firebaseUser.uid)
            .collection(FirestoreConstants.GROUPS_INVITE)
            .doc()
            .set({
          FirestoreConstants.INVITE_ID: documentReference,
          FirestoreConstants.INVITE_ON: DateTime
              .now()
              .millisecondsSinceEpoch,
        });
        await FirebaseFirestore.instance.collection(FirestoreConstants.USER)
            .doc(
            inviteBy)
            .collection(FirestoreConstants.GROUPS_INVITE)
            .doc()
            .set({
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
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.GROUPS)
        .doc(inviteDetails.get(FirestoreConstants.GROUP_NAME))
        .collection(FirestoreConstants.GROUPS_INVITE)
        .doc(inviteDetails.id).update({
      FirestoreConstants.GROUP_INVITE_ACCEPTED: type == 1,
      FirestoreConstants.IS_REJECTED: type == 2,
    });

    if (type == 3) {
      return;
    }

    // check if user is already in the group
    var documents = await FirebaseFirestore.instance
        .collection(FirestoreConstants.USER)
        .doc(inviteDetails.get(FirestoreConstants.GROUP_INVITE_BY))
        .collection(FirestoreConstants.GROUPS)
        .where(FirestoreConstants.GROUP_NAME,
        isEqualTo: inviteDetails.get(FirestoreConstants.GROUP_NAME))
        .get();
    if (documents.docs.length == 0) {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection(FirestoreConstants.GROUPS)
          .doc(inviteDetails.get(FirestoreConstants.GROUP_NAME));
      await documentReference
          .collection(FirestoreConstants.USER)
          .doc(inviteDetails.get(FirestoreConstants.GROUP_INVITE_BY))
          .set({
        FirestoreConstants.JOINED_ON: DateTime
            .now()
            .millisecondsSinceEpoch,
        FirestoreConstants.IS_OWNER: false,
        FirestoreConstants.USER_ID: inviteDetails.get(FirestoreConstants
            .GROUP_INVITE_BY),
      });
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.USER)
          .doc(inviteDetails.get(FirestoreConstants.GROUP_INVITE_BY))
          .collection(FirestoreConstants.GROUPS)
          .doc(inviteDetails.get(FirestoreConstants.GROUP_NAME))
          .set({
        FirestoreConstants.IS_OWNER: false,
        FirestoreConstants.GROUP_NAME: inviteDetails.get(FirestoreConstants
            .GROUP_NAME),
        FirestoreConstants.GROUP_REFERENCE:
        documentReference
      });
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.GROUPS)
          .doc(inviteDetails.get(FirestoreConstants.GROUP_NAME))
          .collection(FirestoreConstants.MESSAGES)
          .doc()
          .set({
        FirestoreConstants.MESSAGE_ON:
        DateTime
            .now()
            .millisecondsSinceEpoch,
        FirestoreConstants.IS_JOINED_MESSAGE: true,
        FirestoreConstants.MESSAGE_BY: inviteDetails.get(FirestoreConstants
            .GROUP_INVITE_BY),
        FirestoreConstants.MESSAGE: "${inviteDetails.get(FirestoreConstants
            .USER_NAME)} joined the group",
        FirestoreConstants.USER_NAME: "${inviteDetails.get(FirestoreConstants
            .USER_NAME)}",
        FirestoreConstants.USER_PROFILE_PIC: "${inviteDetails.get(
            FirestoreConstants
                .USER_PROFILE_PIC)}",
      });
    }
  }
}
