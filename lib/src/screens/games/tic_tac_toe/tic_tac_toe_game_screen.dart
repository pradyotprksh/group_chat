import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/screens/games/tic_tac_toe/tic_tac_toe_game_body.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class TicTacToeGameScreen extends StatelessWidget {
  static const route_name = "tic_tac_toe_game_screen";
  final arguments = Get.arguments as Map<String, dynamic>;

  @override
  Widget build(BuildContext context) {
    final groupName = arguments["groupName"];
    final gameId = arguments["gameId"];

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(FirestoreConstants.GROUPS)
            .doc(groupName)
            .collection(FirestoreConstants.GAMES)
            .doc(StringConstant.TIC_TAC_TOE)
            .collection(FirestoreConstants.GAMES_LIST)
            .doc(gameId)
            .snapshots(),
        builder: (_, gameSnapshot) {
          if (gameSnapshot.connectionState == ConnectionState.waiting) {
            return CenterCircularProgressBar();
          } else if (gameSnapshot.data == null) {
            return CenterText('Not able to find the game');
          } else {
            DocumentSnapshot document = gameSnapshot.data;
            return TicTacToeGameBody(document);
          }
        },
      ),
    );
  }
}
