import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
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
      FirestoreConstants.PLAYERS_DETAILS: [
        {
          FirebaseAuth.instance.currentUser.uid: [
            {FirestoreConstants.USER_ID: FirebaseAuth.instance.currentUser.uid},
            {
              FirestoreConstants.USER_NAME:
                  FirebaseAuth.instance.currentUser.displayName
            },
            {
              FirestoreConstants.USER_PROFILE_PIC:
                  FirebaseAuth.instance.currentUser.photoURL
            }
          ]
        }
      ],
      FirestoreConstants.CREATED_ON: DateTime.now().millisecondsSinceEpoch,
      FirestoreConstants.WINNER: "",
      FirestoreConstants.IS_GAME_ENDED: false,
      FirestoreConstants.CURRENT_PLAYER: FirebaseAuth.instance.currentUser.uid,
      FirestoreConstants.STEPS: [
        {FirestoreConstants.STATE: false, FirestoreConstants.VALUE: ""},
        {FirestoreConstants.STATE: false, FirestoreConstants.VALUE: ""},
        {FirestoreConstants.STATE: false, FirestoreConstants.VALUE: ""},
        {FirestoreConstants.STATE: false, FirestoreConstants.VALUE: ""},
        {FirestoreConstants.STATE: false, FirestoreConstants.VALUE: ""},
        {FirestoreConstants.STATE: false, FirestoreConstants.VALUE: ""},
        {FirestoreConstants.STATE: false, FirestoreConstants.VALUE: ""},
        {FirestoreConstants.STATE: false, FirestoreConstants.VALUE: ""},
        {FirestoreConstants.STATE: false, FirestoreConstants.VALUE: ""},
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
}
