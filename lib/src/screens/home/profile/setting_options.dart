import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/home_controller.dart';
import 'package:group_chat/src/util/firestore_constants.dart';

class SettingOptions extends StatelessWidget {
  final HomeController _homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(FirestoreConstants.USER)
          .doc(FirebaseAuth.instance.currentUser.uid)
          .snapshots(),
      builder: (_, userDataSnapshot) {
        if (userDataSnapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (userDataSnapshot.data == null) {
          return Container();
        } else {
          var userData = userDataSnapshot.data;
          return Column(
            children: [
              ListTile(
                title: Text(
                  "Settings",
                  style: GoogleFonts.asap(
                    fontSize: 20,
                  ),
                ),
              ),
              CheckboxListTile(
                onChanged: (value) {
                  if (value) {
                    _homeController.setupNotification();
                  } else {
                    _homeController.disableNotification();
                  }
                  FirebaseFirestore.instance
                      .collection(FirestoreConstants.USER)
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .update({
                    FirestoreConstants.GET_DAILY_NOTIFICATION: !userData
                        .get(FirestoreConstants.GET_DAILY_NOTIFICATION),
                  });
                },
                activeColor: Theme.of(context).primaryColor,
                value: userData.get(FirestoreConstants.GET_DAILY_NOTIFICATION),
                title: Text(
                  "Daily Notification",
                  style: GoogleFonts.asap(),
                ),
                subtitle: Text(
                  "Get notification for daily game at 10:00 PM.",
                  style: GoogleFonts.asap(),
                ),
              ),
              ListTile(
                subtitle: Text(
                  "** Some devices doesn't allow notification when application is killed. So we would like you to allow the application to run in the background to get the notification **",
                  style: GoogleFonts.asap(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Divider(),
            ],
          );
        }
      },
    );
  }
}
