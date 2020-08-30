import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/games/single_game_list.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class MainGameScreen extends StatelessWidget {
  static const route_name = "main_game_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          "${Get.arguments} Games",
          style: GoogleFonts.asap(),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(FirestoreConstants.GROUPS)
            .doc(Get.arguments)
            .collection(FirestoreConstants.GAMES)
            .where(FirestoreConstants.SHOW_GAME, isEqualTo: true)
            .snapshots(),
        builder: (_, gamesSnapshot) {
          if (gamesSnapshot.connectionState == ConnectionState.waiting) {
            return CenterCircularProgressBar();
          } else if (gamesSnapshot.data == null) {
            return CenterText("No Games Added Yet");
          } else {
            var snapshot = gamesSnapshot.data.documents;
            if (snapshot.length == 0) return CenterText("No Games Added Yet");
            return ListView.builder(
              padding: const EdgeInsets.all(
                5.0,
              ),
              shrinkWrap: true,
              itemCount: snapshot.length,
              itemBuilder: (_, position) {
                DocumentSnapshot document = snapshot[position];
                return SingleGameList(document, Get.arguments);
              },
            );
          }
        },
      ),
    );
  }
}
