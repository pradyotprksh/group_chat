import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/core/controller/chess_board_logic.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class ChessGameScreen extends StatelessWidget {
  static const route_name = "chess_game_screen";
  final arguments = Get.arguments as Map<String, dynamic>;

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
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
            .doc(StringConstant.CHESS)
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
            var boardType;
            if (document.get(FirestoreConstants.BOARD_TYPE) == 0) {
              boardType = BoardType.brown;
            } else if (document.get(FirestoreConstants.BOARD_TYPE) == 1) {
              boardType = BoardType.orange;
            } else if (document.get(FirestoreConstants.BOARD_TYPE) == 2) {
              boardType = BoardType.green;
            } else {
              boardType = BoardType.darkBrown;
            }
            return Center(
              child: ChessBoard(
                size: mediaQuery.width - 20,
                boardType: boardType,
                chessBoardController: ChessBoardLogic(),
                onCheckMate: (String winColor) {},
                onDraw: () {},
                onMove: (String moveNotation) {},
                enableUserMoves:
                    document.get(FirestoreConstants.CURRENT_PLAYER) ==
                        FirebaseAuth.instance.currentUser.uid,
                whiteSideTowardsUser:
                    document.get(FirestoreConstants.CURRENT_PLAYER) ==
                        FirebaseAuth.instance.currentUser.uid,
              ),
            );
          }
        },
      ),
    );
  }
}
