import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/group_list/group_list.dart';

class ProfileGroupDetails extends StatelessWidget {
  final int groupOwner;
  final int groupJoined;
  final String userId;

  ProfileGroupDetails(this.groupOwner, this.groupJoined, this.userId);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Get.toNamed("${GroupList.route_name}?userId=$userId&type=0");
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: 100,
            child: GridTile(
              child: Text(
                "$groupOwner",
                textAlign: TextAlign.center,
                style: GoogleFonts.asap(
                  fontSize: 50,
                ),
              ),
              footer: GridTileBar(
                title: Text(
                  "Group Owner",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.asap(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Get.toNamed("${GroupList.route_name}?userId=$userId&type=1");
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: 100,
            child: GridTile(
              child: Text(
                "$groupJoined",
                textAlign: TextAlign.center,
                style: GoogleFonts.asap(
                  fontSize: 50,
                ),
              ),
              footer: GridTileBar(
                title: Text(
                  "Group Joined",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.asap(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
