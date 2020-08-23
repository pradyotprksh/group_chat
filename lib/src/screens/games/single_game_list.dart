import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/games/memory_checker_game/memory_checker_game.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';

class SingleGameList extends StatelessWidget {
  final DocumentSnapshot document;

  SingleGameList(this.document);

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
            Get.toNamed(MemoryCheckerGame.route_name);
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
