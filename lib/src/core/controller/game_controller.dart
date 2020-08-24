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
      FirestoreConstants.STARTED_ON: 0,
      FirestoreConstants.WINNER: "",
      FirestoreConstants.IS_GAME_ENDED: false,
      FirestoreConstants.IS_GAME_DRAW: false,
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
    Get.back();
    Utility.showSnackBar(
        "Successfully created game. Waiting for someone to join...",
        Colors.green);
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

    /*
    * 0 1 2
    * 3 4 5
    * 6 7 8
    *
    * 0 3 6
    * 1 4 7
    * 2 5 8
    *
    * 0 4 8
    * 2 4 6
    * */

    bool isGameWinnerDecided = false;
    bool isGameDraw = false;

    // 0 1 2
    if (steps[0][FirestoreConstants.STATE] &&
        steps[1][FirestoreConstants.STATE] &&
        steps[2][FirestoreConstants.STATE]) {
      if (steps[0][FirestoreConstants.VALUE] == value &&
          steps[1][FirestoreConstants.VALUE] == value &&
          steps[2][FirestoreConstants.VALUE] == value) {
        isGameWinnerDecided = true;
        steps[0][FirestoreConstants.START_ANIMATION] = true;
        steps[1][FirestoreConstants.START_ANIMATION] = true;
        steps[2][FirestoreConstants.START_ANIMATION] = true;
      }
    }

    // 3 4 5
    if (steps[3][FirestoreConstants.STATE] &&
        steps[4][FirestoreConstants.STATE] &&
        steps[5][FirestoreConstants.STATE]) {
      if (steps[3][FirestoreConstants.VALUE] == value &&
          steps[4][FirestoreConstants.VALUE] == value &&
          steps[5][FirestoreConstants.VALUE] == value) {
        isGameWinnerDecided = true;
        steps[3][FirestoreConstants.START_ANIMATION] = true;
        steps[4][FirestoreConstants.START_ANIMATION] = true;
        steps[5][FirestoreConstants.START_ANIMATION] = true;
      }
    }

    // 6 7 8
    if (steps[6][FirestoreConstants.STATE] &&
        steps[7][FirestoreConstants.STATE] &&
        steps[8][FirestoreConstants.STATE]) {
      if (steps[6][FirestoreConstants.VALUE] == value &&
          steps[7][FirestoreConstants.VALUE] == value &&
          steps[8][FirestoreConstants.VALUE] == value) {
        isGameWinnerDecided = true;
        steps[6][FirestoreConstants.START_ANIMATION] = true;
        steps[7][FirestoreConstants.START_ANIMATION] = true;
        steps[8][FirestoreConstants.START_ANIMATION] = true;
      }
    }

    // 0 3 6
    if (steps[0][FirestoreConstants.STATE] &&
        steps[3][FirestoreConstants.STATE] &&
        steps[6][FirestoreConstants.STATE]) {
      if (steps[0][FirestoreConstants.VALUE] == value &&
          steps[3][FirestoreConstants.VALUE] == value &&
          steps[6][FirestoreConstants.VALUE] == value) {
        isGameWinnerDecided = true;
        steps[0][FirestoreConstants.START_ANIMATION] = true;
        steps[3][FirestoreConstants.START_ANIMATION] = true;
        steps[6][FirestoreConstants.START_ANIMATION] = true;
      }
    }

    // 1 4 7
    if (steps[1][FirestoreConstants.STATE] &&
        steps[4][FirestoreConstants.STATE] &&
        steps[7][FirestoreConstants.STATE]) {
      if (steps[1][FirestoreConstants.VALUE] == value &&
          steps[4][FirestoreConstants.VALUE] == value &&
          steps[7][FirestoreConstants.VALUE] == value) {
        isGameWinnerDecided = true;
        steps[1][FirestoreConstants.START_ANIMATION] = true;
        steps[4][FirestoreConstants.START_ANIMATION] = true;
        steps[7][FirestoreConstants.START_ANIMATION] = true;
      }
    }

    // 2 5 8
    if (steps[2][FirestoreConstants.STATE] &&
        steps[5][FirestoreConstants.STATE] &&
        steps[8][FirestoreConstants.STATE]) {
      if (steps[2][FirestoreConstants.VALUE] == value &&
          steps[5][FirestoreConstants.VALUE] == value &&
          steps[8][FirestoreConstants.VALUE] == value) {
        isGameWinnerDecided = true;
        steps[2][FirestoreConstants.START_ANIMATION] = true;
        steps[5][FirestoreConstants.START_ANIMATION] = true;
        steps[8][FirestoreConstants.START_ANIMATION] = true;
      }
    }

    // 0 4 8
    if (steps[0][FirestoreConstants.STATE] &&
        steps[4][FirestoreConstants.STATE] &&
        steps[8][FirestoreConstants.STATE]) {
      if (steps[0][FirestoreConstants.VALUE] == value &&
          steps[4][FirestoreConstants.VALUE] == value &&
          steps[8][FirestoreConstants.VALUE] == value) {
        isGameWinnerDecided = true;
        steps[0][FirestoreConstants.START_ANIMATION] = true;
        steps[4][FirestoreConstants.START_ANIMATION] = true;
        steps[8][FirestoreConstants.START_ANIMATION] = true;
      }
    }

    // 2 4 6
    if (steps[2][FirestoreConstants.STATE] &&
        steps[4][FirestoreConstants.STATE] &&
        steps[6][FirestoreConstants.STATE]) {
      if (steps[2][FirestoreConstants.VALUE] == value &&
          steps[4][FirestoreConstants.VALUE] == value &&
          steps[6][FirestoreConstants.VALUE] == value) {
        isGameWinnerDecided = true;
        steps[2][FirestoreConstants.START_ANIMATION] = true;
        steps[4][FirestoreConstants.START_ANIMATION] = true;
        steps[6][FirestoreConstants.START_ANIMATION] = true;
      }
    }

    if (steps[0][FirestoreConstants.STATE] &&
        steps[1][FirestoreConstants.STATE] &&
        steps[2][FirestoreConstants.STATE] &&
        steps[3][FirestoreConstants.STATE] &&
        steps[4][FirestoreConstants.STATE] &&
        steps[5][FirestoreConstants.STATE] &&
        steps[6][FirestoreConstants.STATE] &&
        steps[7][FirestoreConstants.STATE] &&
        steps[8][FirestoreConstants.STATE]) {
      if (!isGameWinnerDecided)
        isGameDraw = true;
    }

    FirebaseFirestore.instance
        .doc(document.reference.path).update({
      FirestoreConstants.STEPS: steps,
      FirestoreConstants.IS_GAME_ENDED: isGameWinnerDecided,
      FirestoreConstants.IS_GAME_DRAW: isGameDraw,
      FirestoreConstants.WINNER: isGameWinnerDecided ? FirebaseAuth.instance
          .currentUser.uid : "",
    });
  }
}
