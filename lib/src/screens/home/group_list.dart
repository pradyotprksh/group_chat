import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupList extends StatelessWidget {
  static const route_name = "group_list";
  final String userId = Get.parameters["userId"];
  final String type = Get.parameters["type"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          (type == "0")
              ? "Groups Owned"
              : (type == "1") ? "Groups Joined" : "Groups Invite",
          style: GoogleFonts.asap(),
        ),
      ),
    );
  }
}
