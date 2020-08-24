import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/game_controller.dart';

class CreateTicTacToeGame extends StatelessWidget {
  static const route_name = "create_tic_tac_toe_game";
  final GameController _gameController = Get.find();
  final groupName = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          'Create A Tic-Tac-Toe Game',
          style: GoogleFonts.asap(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Spacer(),
            Text(
              "Since you are creating the game the first chance will be given to you. X",
              textAlign: TextAlign.center,
              style: GoogleFonts.asap(fontSize: 20),
            ),
            Spacer(),
            RaisedButton(
              onPressed: () {
                _gameController.createATicTacToeGame(groupName);
              },
              child: Text(
                'Create Game',
                style: GoogleFonts.asap(
                  fontWeight: FontWeight.bold,
                ),
              ),
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
