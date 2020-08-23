import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/game_controller.dart';
import 'package:group_chat/src/screens/games/tic_tac_toe/create_tic_tac_toe_game.dart';
import 'package:group_chat/src/screens/games/tic_tac_toe/tic_tac_toe_game_screen.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';
import 'package:group_chat/src/util/utility.dart';

class SingleGameList extends StatelessWidget {
  final DocumentSnapshot document;
  final String groupName;
  final GameController _gameController = Get.find();

  SingleGameList(this.document, this.groupName);

  @override
  Widget build(BuildContext context) {
    String name = document.get(FirestoreConstants.GAME_NAME);
    String description = document.get(FirestoreConstants.GAME_DESCRIPTION);
    bool isSinglePlayer = document.get(FirestoreConstants.IS_SINGLE_PLAYER);
    int numberOfPlayers = document.get(FirestoreConstants.NUMBER_OF_PLAYERS);
    List gamePoints = document.get(FirestoreConstants.GAME_POINTS);

    return Card(
      child: ListTile(
        onTap: () {
          if (name == StringConstant.MEMORY_CHECKER) {
          } else if (name == StringConstant.TIC_TAC_TOE) {
            _gameController
                .findIfAnyActiveTicTacToeGame(groupName)
                .then((value) {
              if (value != null && value) {
                Get.toNamed(TicTacToeGameScreen.route_name,
                    arguments: groupName);
              } else {
                Get.toNamed(CreateTicTacToeGame.route_name,
                        arguments: groupName)
                    .then((value) {
                  if (value != null && value) {
                    Utility.showSnackBar(
                      "Game Created Successfully. Waiting for someone to join.",
                      Colors.green,
                    );
                  }
                });
              }
            });
          }
        },
        leading: isSinglePlayer ? Icon(Icons.person) : Icon(Icons.group),
        title: Text(
          name,
          style: GoogleFonts.asap(),
        ),
        subtitle: Text(
          description,
          style: GoogleFonts.asap(),
        ),
        trailing: IconButton(
          onPressed: () {
            Get.bottomSheet(
              Scaffold(
                backgroundColor: Theme.of(context).backgroundColor,
                appBar: AppBar(
                  title: Text(
                    'Extra Info on $name',
                  ),
                  backgroundColor: Theme.of(context).backgroundColor,
                  leading: CloseButton(),
                ),
                body: ListView(
                  children: gamePoints
                      .map(
                        (singlePoint) => ListTile(
                          leading: Icon(
                            Icons.check_circle_outline,
                          ),
                          title: Text(
                            singlePoint,
                            style: GoogleFonts.asap(),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            );
          },
          icon: Icon(
            Icons.info,
          ),
        ),
      ),
    );
  }
}
