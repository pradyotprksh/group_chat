import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class TicTacToeGameScreen extends StatelessWidget {
  static const route_name = "tic_tac_toe_game_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(FirestoreConstants.GROUPS)
            .doc(Get.arguments)
            .collection(FirestoreConstants.GAMES)
            .doc(StringConstant.TIC_TAC_TOE)
            .collection(FirestoreConstants.CURRENT_GAMES)
            .where(FirestoreConstants.PLAYERS,
                arrayContains: FirebaseAuth.instance.currentUser.uid)
            .snapshots(),
        builder: (_, gameSnapshot) {
          if (gameSnapshot.connectionState == ConnectionState.waiting) {
            return CenterCircularProgressBar();
          } else if (gameSnapshot.data == null) {
            return CenterText('Not able to find the game');
          } else {
            var snapshot = gameSnapshot.data.documents;
            if (snapshot.length == 0) {
              return CenterText('Not able to find the game');
            }
            DocumentSnapshot document = snapshot[0];
            return Container();
          }
        },
      ),
    );
  }
}
