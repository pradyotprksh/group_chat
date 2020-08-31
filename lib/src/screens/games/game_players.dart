import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/util/firestore_constants.dart';

class GamePlayers extends StatelessWidget {
  final DocumentSnapshot document;

  GamePlayers(this.document);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: Text(
              document.get(FirestoreConstants.PLAYER_0_USER_NAME),
              style: GoogleFonts.asap(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Text(
          "VS",
          style: GoogleFonts.share(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (document.get(FirestoreConstants.PLAYERS).length == 2)
          Expanded(
            child: ListTile(
              title: Text(
                document.get(FirestoreConstants.PLAYER_1_USER_NAME),
                textAlign: TextAlign.end,
                style: GoogleFonts.asap(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (document.get(FirestoreConstants.PLAYERS).length == 1)
          Expanded(
            child: Text(
              'No Player Joined Yet',
              textAlign: TextAlign.end,
              style: GoogleFonts.asap(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
