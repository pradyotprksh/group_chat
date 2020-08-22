import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/util/firestore_constants.dart';

class OtherMessageWidget extends StatelessWidget {
  final DocumentSnapshot snapshot;

  OtherMessageWidget(this.snapshot);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 15.0,
        ),
        padding: const EdgeInsets.fromLTRB(
          15.0,
          5.0,
          15.0,
          5.0,
        ),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: const BorderRadius.all(
            Radius.circular(
              15.0,
            ),
          ),
        ),
        child: Text(
          "${snapshot.get(FirestoreConstants.MESSAGE)}",
          style: GoogleFonts.asap(),
        ),
      ),
    );
  }
}
