import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/game_controller.dart';
import 'package:group_chat/src/screens/games/game_players.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TicTacToeGameBody extends StatelessWidget {
  final DocumentSnapshot document;
  final String groupName;
  final GameController _gameController = Get.find();

  TicTacToeGameBody(this.document, this.groupName);

  @override
  Widget build(BuildContext context) {
    var steps = document.get(FirestoreConstants.STEPS);

    return Padding(
      padding: const EdgeInsets.all(
        15.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GamePlayers(document),
          if (document.get(FirestoreConstants.PLAYERS).length == 1)
            Padding(
              padding: const EdgeInsets.all(
                15.0,
              ),
              child: Text(
                "You can't start game until someone joins.",
                textAlign: TextAlign.center,
                style: GoogleFonts.asap(fontStyle: FontStyle.italic),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(
              15.0,
            ),
            child: (document.get(FirestoreConstants.CREATED_BY) ==
                    FirebaseAuth.instance.currentUser.uid)
                ? Text(
                    "You are X",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.asap(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  )
                : Text(
                    "You are O",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.asap(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
          ),
          Spacer(),
          GridView.builder(
            shrinkWrap: true,
            itemCount: steps.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 15.0,
              mainAxisSpacing: 15.0,
            ),
            itemBuilder: (_, position) {
              var singleStep = steps[position];
              return ShakeAnimatedWidget(
                enabled: singleStep[FirestoreConstants.START_ANIMATION],
                duration: Duration(milliseconds: 1000),
                shakeAngle: Rotation.deg(
                  z: 5,
                ),
                curve: Curves.linear,
                child: RaisedButton(
                  onPressed: () {
                    if (!document.get(FirestoreConstants.IS_GAME_ENDED)) {
                      if (document.get(FirestoreConstants.PLAYERS).length ==
                          2) {
                        if (document.get(FirestoreConstants.CURRENT_PLAYER) ==
                            FirebaseAuth.instance.currentUser.uid) {
                          var steps = document.get(FirestoreConstants.STEPS);
                          if (!steps[position][FirestoreConstants.STATE]) {
                            _gameController.updateGame(
                                document,
                                groupName,
                                position,
                                FirebaseAuth.instance.currentUser.uid ==
                                        document
                                            .get(FirestoreConstants.CREATED_BY)
                                    ? "X"
                                    : "O");
                          } else {
                            Utility.showSnackBar(
                                "Place already Taken...", Colors.red);
                          }
                        } else {
                          Utility.showSnackBar(
                              "Its not your turn...", Colors.red);
                        }
                      } else {
                        Utility.showSnackBar(
                            "No one has joined the match yet...", Colors.red);
                      }
                    } else {
                      if (document.get(FirestoreConstants.IS_GAME_DRAW)) {
                        Utility.showSnackBar("Game is a draw...", Colors.red);
                      } else {
                        if (document.get(FirestoreConstants.WINNER) ==
                            FirebaseAuth.instance.currentUser.uid) {
                          Utility.showSnackBar(
                              "You are the winner already...", Colors.green);
                        } else {
                          Utility.showSnackBar(
                              "You lost this game already...", Colors.red);
                        }
                      }
                    }
                  },
                  color: singleStep[FirestoreConstants.START_ANIMATION]
                      ? Colors.green
                      : Theme.of(context).primaryColor,
                  child: singleStep[FirestoreConstants.STATE]
                      ? singleStep[FirestoreConstants.VALUE] == "X"
                          ? Text(
                              "X",
                              style: GoogleFonts.asap(
                                fontSize: 100,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              "O",
                              style: GoogleFonts.asap(
                                fontSize: 100,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                      : Icon(
                          MdiIcons.cursorPointer,
                          size: 100,
                        ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20.0,
                    ),
                  ),
                ),
              );
            },
          ),
          Spacer(),
          if (document.get(FirestoreConstants.PLAYERS).length == 2 &&
              document.get(FirestoreConstants.CURRENT_PLAYER) !=
                  FirebaseAuth.instance.currentUser.uid &&
              !document.get(FirestoreConstants.IS_GAME_ENDED))
            Padding(
              padding: const EdgeInsets.all(
                15.0,
              ),
              child: Text(
                "Waiting For Other Player To Make The Move...",
                textAlign: TextAlign.center,
                style: GoogleFonts.asap(),
              ),
            ),
          if (document.get(FirestoreConstants.PLAYERS).length == 2 &&
              document.get(FirestoreConstants.CURRENT_PLAYER) ==
                  FirebaseAuth.instance.currentUser.uid &&
              !document.get(FirestoreConstants.IS_GAME_ENDED))
            Padding(
              padding: const EdgeInsets.all(
                15.0,
              ),
              child: Text(
                "Your turn...",
                textAlign: TextAlign.center,
                style: GoogleFonts.asap(),
              ),
            ),
          if (document.get(FirestoreConstants.IS_GAME_ENDED) &&
              document.get(FirestoreConstants.IS_GAME_DRAW))
            Padding(
              padding: const EdgeInsets.all(
                15.0,
              ),
              child: Text(
                "This game was a draw...",
                textAlign: TextAlign.center,
                style: GoogleFonts.asap(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          if (document.get(FirestoreConstants.IS_GAME_ENDED) &&
              !document.get(FirestoreConstants.IS_GAME_DRAW) &&
              document.get(FirestoreConstants.WINNER) ==
                  FirebaseAuth.instance.currentUser.uid)
            Padding(
              padding: const EdgeInsets.all(
                15.0,
              ),
              child: Text(
                "YOU WON",
                textAlign: TextAlign.center,
                style: GoogleFonts.asap(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 20,
                ),
              ),
            ),
          if (document.get(FirestoreConstants.IS_GAME_ENDED) &&
              !document.get(FirestoreConstants.IS_GAME_DRAW) &&
              document.get(FirestoreConstants.WINNER) !=
                  FirebaseAuth.instance.currentUser.uid)
            Padding(
              padding: const EdgeInsets.all(
                15.0,
              ),
              child: Text(
                "YOU LOOSE",
                textAlign: TextAlign.center,
                style: GoogleFonts.asap(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
            ),
          if (FirebaseAuth.instance.currentUser.uid ==
                  document.get(FirestoreConstants.CREATED_BY) &&
              (document.get(FirestoreConstants.PLAYERS).length == 1 ||
                  document.get(FirestoreConstants.IS_GAME_ENDED)))
            RaisedButton(
              onPressed: () {
                _gameController.deleteGame(document);
              },
              color: Colors.red,
              child: Text(
                'Delete The Game',
                style: GoogleFonts.asap(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
