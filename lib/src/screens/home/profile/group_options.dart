import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/group_list/group_list.dart';

class GroupOptions extends StatelessWidget {
  final String userId;

  GroupOptions(this.userId);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            "Groups",
            style: GoogleFonts.asap(
              fontSize: 20,
            ),
          ),
        ),
        ListTile(
          onTap: () {
            Get.toNamed("${GroupList.route_name}?userId=$userId&type=0");
          },
          title: Text(
            "Group owned",
            style: GoogleFonts.asap(),
          ),
          subtitle: Text(
            "See list of groups owned by you.",
            style: GoogleFonts.asap(),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
          ),
        ),
        ListTile(
          onTap: () {
            Get.toNamed("${GroupList.route_name}?userId=$userId&type=1");
          },
          title: Text(
            "Group joined",
            style: GoogleFonts.asap(),
          ),
          subtitle: Text(
            "See list of groups joined by you.",
            style: GoogleFonts.asap(),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
          ),
        ),
        ListTile(
          onTap: () {
            Get.toNamed("${GroupList.route_name}?userId=$userId&type=2");
          },
          title: Text(
            "Group invites",
            style: GoogleFonts.asap(),
          ),
          subtitle: Text(
            "See list of groups invites.",
            style: GoogleFonts.asap(),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
          ),
        ),
      ],
    );
  }
}
