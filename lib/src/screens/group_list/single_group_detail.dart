import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/group_chat/group_chat_screen.dart';
import 'package:group_chat/src/screens/group_detail_bottom_sheet/group_detail_bottom_sheet.dart';
import 'package:group_chat/src/util/firestore_constants.dart';

class SingleGroupDetail extends StatelessWidget {
  final DocumentSnapshot snapshot;

  SingleGroupDetail(this.snapshot);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        bottom: 15.0,
      ),
      height: 150,
      child: GestureDetector(
        onTap: () {
          Get.toNamed(GroupChatScreen.route_name,
              arguments: snapshot[FirestoreConstants.GROUP_NAME]);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          clipBehavior: Clip.antiAlias,
          child: GridTile(
            child: FadeInImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                snapshot[FirestoreConstants.GROUP_BACKGROUND_IMAGE],
              ),
              placeholder: AssetImage("assets/default_group_background.jpg"),
            ),
            footer: GridTileBar(
              backgroundColor: Colors.black54,
              title: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(
                      5.0,
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.all(
                          8.0,
                        ),
                        child: Image.network(
                          snapshot[FirestoreConstants.GROUP_PROFILE_IMAGE],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    snapshot[FirestoreConstants.GROUP_NAME],
                    style: GoogleFonts.asap(fontSize: 18.0),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      Get.bottomSheet(GroupDetailBottomSheet(
                          snapshot[FirestoreConstants.GROUP_NAME]));
                    },
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
