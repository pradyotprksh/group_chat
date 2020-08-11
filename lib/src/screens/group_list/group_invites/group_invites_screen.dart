import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupInvitesScreen extends StatelessWidget {
  static const route_name = "group_invite_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          "Groups Joined",
          style: GoogleFonts.asap(),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.history,
            ),
          ),
        ],
      ),
    );
  }
}
