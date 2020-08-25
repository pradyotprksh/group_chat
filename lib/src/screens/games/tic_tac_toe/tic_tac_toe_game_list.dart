import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_chat/src/core/controller/game_controller.dart';
import 'package:group_chat/src/screens/games/tic_tac_toe/tic_tac_toe_single_game_list.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class TicTacToeGameList extends StatelessWidget {
  final GameController _gameController = Get.find();
  static const route_name = "tic_tac_toe_game_list";
  final groupName = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text("${StringConstant.TIC_TAC_TOE} Active Games"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.history,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(FirestoreConstants.GROUPS)
            .doc(groupName)
            .collection(FirestoreConstants.GAMES)
            .doc(StringConstant.TIC_TAC_TOE)
            .collection(FirestoreConstants.GAMES_LIST)
            .where(FirestoreConstants.IS_GAME_ENDED, isEqualTo: false)
            .snapshots(),
        builder: (_, gamesSnapshot) {
          if (gamesSnapshot.connectionState == ConnectionState.waiting) {
            return CenterCircularProgressBar();
          } else if (gamesSnapshot.data == null) {
            return CenterText("No games created yet. Be the first.");
          } else {
            var snapshot = gamesSnapshot.data.documents;
            if (snapshot.length == 0)
              return CenterText("No games created yet. Be the first.");
            return ListView.builder(
              padding: const EdgeInsets.all(
                5.0,
              ),
              shrinkWrap: true,
              itemCount: snapshot.length,
              itemBuilder: (_, position) {
                return TicTacToeSingleGameList(snapshot[position], groupName);
              },
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: "Create A Game",
        child: Icon(
          Icons.create,
        ),
        onPressed: () {
          _gameController.findIfAnyActiveTicTacToeGame(groupName);
        },
      ),
    );
  }
}
