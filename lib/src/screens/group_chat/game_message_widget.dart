import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/games/chess/chess_game_list.dart';
import 'package:group_chat/src/screens/games/tic_tac_toe/tic_tac_toe_game_list.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';

class GameMessageWidget extends StatelessWidget {
  final DocumentSnapshot snapshot;
  final String groupName;

  GameMessageWidget(this.snapshot, this.groupName);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 15.0,
        ),
        child: RaisedButton(
          onPressed: () {
            if (snapshot.get(FirestoreConstants.GAME_NAME) ==
                StringConstant.TIC_TAC_TOE) {
              Get.toNamed(TicTacToeGameList.route_name, arguments: groupName);
            } else if (snapshot.get(FirestoreConstants.GAME_NAME) ==
                StringConstant.CHESS) {
              Get.toNamed(ChessGameList.route_name, arguments: groupName);
            }
          },
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20.0,
            ),
          ),
          splashColor: Colors.redAccent,
          padding: const EdgeInsets.fromLTRB(
            15.0,
            5.0,
            15.0,
            5.0,
          ),
          child: Text(
            "${snapshot.get(FirestoreConstants.MESSAGE)}",
            style: GoogleFonts.asap(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
