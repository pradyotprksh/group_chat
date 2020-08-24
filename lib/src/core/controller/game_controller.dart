import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';
import 'package:group_chat/src/util/utility.dart';

class GameController extends GetxController {
  void createATicTacToeGame(String groupName) async {
    Utility.showLoadingDialog("Create the game environment");
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.GROUPS)
        .doc(groupName)
        .collection(FirestoreConstants.GAMES)
        .doc(StringConstant.TIC_TAC_TOE)
        .collection(FirestoreConstants.CURRENT_GAMES)
        .doc()
        .set({
      FirestoreConstants.CREATED_BY: FirebaseAuth.instance.currentUser.uid,
      FirestoreConstants.PLAYERS: [FirebaseAuth.instance.currentUser.uid],
      FirestoreConstants.PLAYER_0_USER_ID:
          FirebaseAuth.instance.currentUser.uid,
      FirestoreConstants.PLAYER_0_USER_NAME:
          FirebaseAuth.instance.currentUser.displayName,
      FirestoreConstants.PLAYER_0_USER_PROFILE_PIC:
          FirebaseAuth.instance.currentUser.photoURL,
      FirestoreConstants.PLAYER_1_USER_ID: "",
      FirestoreConstants.PLAYER_1_USER_NAME: "",
      FirestoreConstants.PLAYER_1_USER_PROFILE_PIC: "",
      FirestoreConstants.CREATED_ON: DateTime.now().millisecondsSinceEpoch,
      FirestoreConstants.WINNER: "",
      FirestoreConstants.IS_GAME_ENDED: false,
      FirestoreConstants.CURRENT_PLAYER: FirebaseAuth.instance.currentUser.uid,
      FirestoreConstants.STEPS: [
        {
          FirestoreConstants.STATE: false,
          FirestoreConstants.VALUE: "",
          FirestoreConstants.START_ANIMATION: false,
        },
        {
          FirestoreConstants.STATE: false,
          FirestoreConstants.VALUE: "",
          FirestoreConstants.START_ANIMATION: false,
        },
        {
          FirestoreConstants.STATE: false,
          FirestoreConstants.VALUE: "",
          FirestoreConstants.START_ANIMATION: false,
        },
        {
          FirestoreConstants.STATE: false,
          FirestoreConstants.VALUE: "",
          FirestoreConstants.START_ANIMATION: false,
        },
        {
          FirestoreConstants.STATE: false,
          FirestoreConstants.VALUE: "",
          FirestoreConstants.START_ANIMATION: false,
        },
        {
          FirestoreConstants.STATE: false,
          FirestoreConstants.VALUE: "",
          FirestoreConstants.START_ANIMATION: false,
        },
        {
          FirestoreConstants.STATE: false,
          FirestoreConstants.VALUE: "",
          FirestoreConstants.START_ANIMATION: false,
        },
        {
          FirestoreConstants.STATE: false,
          FirestoreConstants.VALUE: "",
          FirestoreConstants.START_ANIMATION: false,
        },
        {
          FirestoreConstants.STATE: false,
          FirestoreConstants.VALUE: "",
          FirestoreConstants.START_ANIMATION: false,
        },
      ]
    });
    Get.back();
    Get.back(result: true);
  }

  Future<bool> findIfAnyActiveTicTacToeGame(String groupName) async {
    Utility.showLoadingDialog("Checking something");
    var currentGames = await FirebaseFirestore.instance
        .collection(FirestoreConstants.GROUPS)
        .doc(groupName)
        .collection(FirestoreConstants.GAMES)
        .doc(StringConstant.TIC_TAC_TOE)
        .collection(FirestoreConstants.CURRENT_GAMES)
        .where(FirestoreConstants.PLAYERS,
        arrayContains: FirebaseAuth.instance.currentUser.uid)
        .get();
    Get.back();
    if (currentGames.docs.length > 0) {
      return true;
    }
    return false;
  }

  void deleteGame(DocumentSnapshot document) async {
    Get.defaultDialog(
      title: "Delete",
      content: Text(
        "You sure you want to delete the game?",
        style: GoogleFonts.asap(),
      ),
      confirmTextColor: Colors.white,
      textConfirm: "Yes",
      textCancel: "No",
      onConfirm: () async {
        Get.back();
        Utility.showLoadingDialog("Deleting game...");
        await FirebaseFirestore.instance.doc(document.reference.path).delete();
        Get.back();
        Get.back(result: true);
      },
    );
  }

  void updateGame(DocumentSnapshot document, int position, String value) {
    var steps = document.get(FirestoreConstants.STEPS);
    var updateItem = {
      FirestoreConstants.STATE: true,
      FirestoreConstants.VALUE: value,
      FirestoreConstants.START_ANIMATION: false
    };
    steps[position] = updateItem;
    FirebaseFirestore.instance
        .doc(document.reference.path).update({
      FirestoreConstants.STEPS: steps
    });
  }
}
