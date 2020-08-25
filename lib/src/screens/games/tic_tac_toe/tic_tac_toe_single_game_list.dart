import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/game_controller.dart';
import 'package:group_chat/src/screens/games/tic_tac_toe/tic_tac_toe_game_players.dart';
import 'package:group_chat/src/screens/games/tic_tac_toe/tic_tac_toe_game_screen.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';

class TicTacToeSingleGameList extends StatelessWidget {
  final DocumentSnapshot snapshot;
  final String groupName;
  final GameController _gameController = Get.find();

  TicTacToeSingleGameList(this.snapshot, this.groupName);

  @override
  Widget build(BuildContext context) {
    var players = snapshot.get(FirestoreConstants.PLAYERS);

    return Card(
      color: Colors.black,
      child: InkWell(
        onTap: () {
          if (players.contains(FirebaseAuth.instance.currentUser.uid)) {
            Get.toNamed(TicTacToeGameScreen.route_name,
                arguments: {"groupName": groupName, "gameId": snapshot.id});
          } else {
            Utility.showSnackBar(
                "You need to join as a player to see the status.", Colors.red);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(
            15.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TicTacToeGamePlayers(snapshot),
              if (players.length == 1 &&
                  !players.contains(FirebaseAuth.instance.currentUser.uid))
                RaisedButton(
                  onPressed: () {
                    _gameController.joinMatch(snapshot, groupName);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20.0,
                    ),
                  ),
                  child: Text(
                    "Join Match",
                    style: GoogleFonts.asap(),
                  ),
                ),
              if (players.contains(FirebaseAuth.instance.currentUser.uid))
                RaisedButton(
                  onPressed: () {
                    if (players
                        .contains(FirebaseAuth.instance.currentUser.uid)) {
                      Get.toNamed(TicTacToeGameScreen.route_name, arguments: {
                        "groupName": groupName,
                        "gameId": snapshot.id
                      });
                    } else {
                      Utility.showSnackBar(
                          "You need to join as a player to see the status.",
                          Colors.red);
                    }
                  },
                  color: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20.0,
                    ),
                  ),
                  child: Text(
                    "Start Playing...",
                    style: GoogleFonts.asap(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
