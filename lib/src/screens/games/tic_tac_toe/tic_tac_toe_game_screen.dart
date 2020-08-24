import 'package:animated_widgets/animated_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/game_controller.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TicTacToeGameScreen extends StatelessWidget {
  static const route_name = "tic_tac_toe_game_screen";
  final GameController _gameController = Get.find();

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
            var steps = document.get(FirestoreConstants.STEPS);

            return Padding(
              padding: const EdgeInsets.all(
                15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            document.get(FirestoreConstants.PLAYER_0_USER_NAME),
                            style: GoogleFonts.asap(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: (document
                              .get(FirestoreConstants.CURRENT_PLAYER) ==
                              FirebaseAuth.instance.currentUser.uid)
                              ? Text(
                            "Your Turn",
                            style: GoogleFonts.asap(
                              color: Colors.greenAccent,
                            ),
                          )
                              : Text(
                            "Waiting for ${document.get(
                                FirestoreConstants.PLAYER_1_USER_NAME)}...",
                            style: GoogleFonts.asap(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      if (document
                          .get(FirestoreConstants.PLAYERS)
                          .length == 2)
                        Expanded(
                          child: ListTile(
                            title: Text(
                              document
                                  .get(FirestoreConstants.PLAYER_1_USER_NAME),
                              style: GoogleFonts.asap(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: (document.get(
                                FirestoreConstants.CURRENT_PLAYER) !=
                                FirebaseAuth.instance.currentUser.uid)
                                ? Text(
                              "Is Thinking...",
                              style: GoogleFonts.asap(
                                color: Colors.greenAccent,
                              ),
                            )
                                : Text(
                              "Is Waiting...",
                              style: GoogleFonts.asap(
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      if (document
                          .get(FirestoreConstants.PLAYERS)
                          .length == 1)
                        Expanded(
                          child: Text(
                            'No Player Joined Yet',
                            style: GoogleFonts.asap(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Spacer(),
                  if (document
                      .get(FirestoreConstants.PLAYERS)
                      .length == 1)
                    Padding(
                      padding: const EdgeInsets.all(15.0,),
                      child: Text("You can start game until someone joins.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.asap(fontStyle: FontStyle.italic),),
                    ),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: steps.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 9.0,
                      mainAxisSpacing: 9.0,),
                    itemBuilder: (_, position) {
                      var singleStep = steps[position];
                      return ShakeAnimatedWidget(
                        enabled: singleStep[FirestoreConstants.START_ANIMATION],
                        duration: Duration(milliseconds: 1500),
                        shakeAngle: Rotation.deg(z: 5,),
                        curve: Curves.linear,
                        child: RaisedButton(
                          onPressed: (document
                              .get(FirestoreConstants.PLAYERS)
                              .length != 1) ? null : () {
                            _gameController.updateGame(document, position,
                                FirebaseAuth.instance.currentUser.uid ==
                                    document.get(FirestoreConstants.CREATED_BY)
                                    ? "X"
                                    : "O");
                          },
                          child: singleStep[FirestoreConstants.STATE]
                              ? singleStep[FirestoreConstants.VALUE] == "X"
                              ? Text("X", style: GoogleFonts.asap(
                            fontSize: 100, fontWeight: FontWeight.bold,),)
                              : Text("O", style: GoogleFonts.asap(
                            fontSize: 100, fontWeight: FontWeight.bold,),)
                              : Icon(MdiIcons.cursorPointer, size: 100,),
                        ),
                      );
                    },
                  ),
                  Spacer(),
                  if (document
                      .get(FirestoreConstants.PLAYERS)
                      .length == 1)
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
        },
      ),
    );
  }
}
