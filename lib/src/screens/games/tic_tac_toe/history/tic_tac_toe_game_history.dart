import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/games/tic_tac_toe/tic_tac_toe_game_screen.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';
import 'package:group_chat/src/util/utility.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TicTacToeGameHistory extends StatelessWidget {
  final String groupName;

  TicTacToeGameHistory(this.groupName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: CloseButton(),
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text("${StringConstant.TIC_TAC_TOE} History"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(FirestoreConstants.GROUPS)
            .doc(groupName)
            .collection(FirestoreConstants.GAMES)
            .doc(StringConstant.TIC_TAC_TOE)
            .collection(FirestoreConstants.GAMES_LIST)
            .where(FirestoreConstants.IS_GAME_ENDED, isEqualTo: true)
            .where(FirestoreConstants.PLAYERS,
                arrayContains: FirebaseAuth.instance.currentUser.uid)
            .orderBy(FirestoreConstants.GAME_ENDED_ON, descending: true)
            .snapshots(),
        builder: (_, gamesSnapshot) {
          if (gamesSnapshot.connectionState == ConnectionState.waiting) {
            return CenterCircularProgressBar();
          } else if (gamesSnapshot.data == null) {
            return CenterText("No games played yet. Be the first.");
          } else {
            var snapshots = gamesSnapshot.data.documents;
            if (snapshots.length == 0)
              return CenterText("No games played yet. Be the first.");
            return ListView.builder(
              padding: const EdgeInsets.all(
                5.0,
              ),
              shrinkWrap: true,
              itemCount: snapshots.length,
              itemBuilder: (_, position) {
                DocumentSnapshot snapshot = snapshots[position];
                return ListTile(
                  onTap: () {
                    Get.toNamed(TicTacToeGameScreen.route_name, arguments: {
                      "groupName": groupName,
                      "gameId": snapshot.id
                    });
                  },
                  leading: Icon(
                    MdiIcons.gamepadVariantOutline,
                  ),
                  title: (snapshot.get(FirestoreConstants.IS_GAME_DRAW))
                      ? Text(
                          "Game was a draw",
                          style: GoogleFonts.asap(),
                        )
                      : (snapshot.get(FirestoreConstants.WINNER) ==
                              FirebaseAuth.instance.currentUser.uid)
                          ? Text(
                              "You won the match",
                              style: GoogleFonts.asap(color: Colors.green),
                            )
                          : Text(
                              "You loose the match",
                              style: GoogleFonts.asap(color: Colors.red),
                            ),
                  subtitle: Text(
                      "Game started on ${Utility.getTimeFromTimeStamp(snapshot.get(FirestoreConstants.STARTED_ON))} and ended on ${Utility.getTimeFromTimeStamp(snapshot.get(FirestoreConstants.GAME_ENDED_ON))}"),
                  isThreeLine: true,
                );
              },
            );
          }
        },
      ),
    );
  }
}
