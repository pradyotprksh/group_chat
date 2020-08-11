import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';

class GroupController extends GetxController {
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
        await Firestore.instance
            .collection(FirestoreConstants.GROUPS)
            .document(groupName)
            .collection(FirestoreConstants.GROUPS_INVITE)
            .document("${firebaseUser.uid}$groupName$inviteBy")
            .setData({
          FirestoreConstants.GROUP_NAME: groupName,
          FirestoreConstants.GROUP_INVITE_TO: inviteBy,
          FirestoreConstants.GROUP_INVITE_BY: firebaseUser.uid,
          FirestoreConstants.USER_NAME: firebaseUser.displayName,
          FirestoreConstants.USER_PROFILE_PIC: firebaseUser.photoUrl,
          FirestoreConstants.INVITE_ON: DateTime.now().millisecondsSinceEpoch,
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
}
