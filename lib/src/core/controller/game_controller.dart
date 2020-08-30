import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/games/tic_tac_toe/tic_tac_toe_game_screen.dart';
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
        .collection(FirestoreConstants.GAMES_LIST)
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
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.GROUPS)
        .doc(StringConstant.APP_NAME)
        .collection(FirestoreConstants.MESSAGES)
        .doc()
        .set({
      FirestoreConstants.MESSAGE_ON: DateTime.now().millisecondsSinceEpoch,
      FirestoreConstants.IS_GAME_MESSAGE: true,
      FirestoreConstants.GAME_NAME: StringConstant.TIC_TAC_TOE,
      FirestoreConstants.MESSAGE_BY: FirebaseAuth.instance.currentUser.uid,
      FirestoreConstants.MESSAGE:
          "${FirebaseAuth.instance.currentUser.displayName} created a Tic-Tac-Toe game",
      FirestoreConstants.USER_NAME:
          "${FirebaseAuth.instance.currentUser.displayName}",
      FirestoreConstants.USER_PROFILE_PIC:
          "${FirebaseAuth.instance.currentUser.photoURL}",
    });
    Get.back();
    Get.back();
    Utility.showSnackBar(
        "Successfully created game. Waiting for someone to join...",
        Colors.green);
  }

  void findIfAnyActiveTicTacToeGame(String groupName) async {
    Utility.showLoadingDialog("Checking something");
    var currentGames = await FirebaseFirestore.instance
        .collection(FirestoreConstants.GROUPS)
        .doc(groupName)
        .collection(FirestoreConstants.GAMES)
        .doc(StringConstant.TIC_TAC_TOE)
        .collection(FirestoreConstants.GAMES_LIST)
        .where(FirestoreConstants.PLAYERS,
            arrayContains: FirebaseAuth.instance.currentUser.uid)
        .where(FirestoreConstants.IS_GAME_ENDED, isEqualTo: false)
        .get();
    Get.back();
    if (currentGames.docs.length > 0) {
      Get.toNamed(TicTacToeGameScreen.route_name, arguments: {
        "groupName": groupName,
        "gameId": currentGames.docs[0].id
      }).then((value) async {
        if (value != null) {
          DocumentSnapshot document = value;
          Utility.showLoadingDialog("Deleting game...");
          await FirebaseFirestore.instance.doc(document.reference.path)
              .delete();
          Get.back();
        }
      });
    } else {
      Get.defaultDialog(
        title: "Alert",
        content: Text(
          'Create A Game?',
          style: GoogleFonts.asap(
            color: Colors.white,
          ),
        ),
        textCancel: "Nope",
        textConfirm: "Yes",
        confirmTextColor: Colors.white,
        onConfirm: () {
          createATicTacToeGame(groupName);
        },
      );
    }
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
        Get.back(result: document);
      },
    );
  }

  void updateGame(DocumentSnapshot document, String groupName, int position,
      String value) async {
    Utility.showLoadingDialog("Updating Game...");
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
      if (!isGameWinnerDecided) {
        isGameDraw = true;
        isGameWinnerDecided = true;
        steps[0][FirestoreConstants.START_ANIMATION] = true;
        steps[1][FirestoreConstants.START_ANIMATION] = true;
        steps[2][FirestoreConstants.START_ANIMATION] = true;
        steps[3][FirestoreConstants.START_ANIMATION] = true;
        steps[4][FirestoreConstants.START_ANIMATION] = true;
        steps[5][FirestoreConstants.START_ANIMATION] = true;
        steps[6][FirestoreConstants.START_ANIMATION] = true;
        steps[7][FirestoreConstants.START_ANIMATION] = true;
        steps[8][FirestoreConstants.START_ANIMATION] = true;
      }
    }

    var gameHistoryData = {
      FirestoreConstants.STEPS: steps,
      FirestoreConstants.IS_GAME_ENDED: isGameWinnerDecided,
      FirestoreConstants.IS_GAME_DRAW: isGameDraw,
      FirestoreConstants.WINNER:
          isGameWinnerDecided ? FirebaseAuth.instance.currentUser.uid : "",
      FirestoreConstants.CURRENT_PLAYER: (value == "X")
          ? document.get(FirestoreConstants.PLAYERS)[1]
          : document.get(FirestoreConstants.PLAYERS)[0],
    };
    if (isGameWinnerDecided) {
      gameHistoryData[FirestoreConstants.GAME_ENDED_ON] =
          DateTime.now().millisecondsSinceEpoch;
    }

    await FirebaseFirestore.instance
        .doc(document.reference.path)
        .update(gameHistoryData);
    Get.back();
  }

  void joinMatch(DocumentSnapshot snapshot, String groupName) async {
    Utility.showLoadingDialog("Joining Match...");
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.GROUPS)
        .doc(groupName)
        .collection(FirestoreConstants.GAMES)
        .doc(StringConstant.TIC_TAC_TOE)
        .collection(FirestoreConstants.GAMES_LIST)
        .doc(snapshot.id).update({
      FirestoreConstants.PLAYERS: [
        snapshot.get(FirestoreConstants.PLAYERS)[0],
        FirebaseAuth.instance.currentUser.uid
      ],
      FirestoreConstants.PLAYER_1_USER_ID: FirebaseAuth.instance.currentUser
          .uid,
      FirestoreConstants.PLAYER_1_USER_NAME: FirebaseAuth.instance.currentUser
          .displayName,
      FirestoreConstants.PLAYER_1_USER_PROFILE_PIC: FirebaseAuth.instance
          .currentUser.photoURL,
      FirestoreConstants.STARTED_ON: DateTime
          .now()
          .millisecondsSinceEpoch,
    });
    Get.back();
    Get.toNamed(TicTacToeGameScreen.route_name, arguments: {
      "groupName": groupName,
      "gameId": snapshot.id
    }).then((value) async {
      if (value != null) {
        DocumentSnapshot document = value;
        Future.delayed(const Duration(milliseconds: 100), () {
          FirebaseFirestore.instance.doc(document.reference.path).delete();
        });
      }
    });
  }
}
