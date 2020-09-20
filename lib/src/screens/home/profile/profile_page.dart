import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/core/controller/auth_controller.dart';
import 'package:group_chat/src/screens/create_group.dart';
import 'package:group_chat/src/screens/home/profile/group_options.dart';
import 'package:group_chat/src/screens/home/profile/other_options.dart';
import 'package:group_chat/src/screens/home/profile/profile_group_details.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/widget/center_circular_progressbar.dart';
import 'package:group_chat/src/widget/center_text.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection(FirestoreConstants.USER)
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get(),
      builder: (_, userDataSnapshot) {
        if (userDataSnapshot.connectionState == ConnectionState.waiting) {
          return CenterCircularProgressBar();
        } else if (userDataSnapshot.data == null) {
          return CenterText("Something Went Wrong while getting user data.");
        } else {
          var userData = userDataSnapshot.data;
          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection(FirestoreConstants.USER)
                .doc(FirebaseAuth.instance.currentUser.uid)
                .collection(FirestoreConstants.GROUPS)
                .where(FirestoreConstants.IS_OWNER, isEqualTo: true)
                .get(),
            builder: (_, groupOwnerSnapshot) {
              if (groupOwnerSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return CenterCircularProgressBar();
              }
              var groupOwner = 0;
              if (groupOwnerSnapshot.data != null) {
                groupOwner = groupOwnerSnapshot.data.documents.length;
              }
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection(FirestoreConstants.USER)
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .collection(FirestoreConstants.GROUPS)
                    .get(),
                builder: (_, groupJoinedSnapshot) {
                  if (groupJoinedSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CenterCircularProgressBar();
                  }
                  var groupJoined = 0;
                  if (groupJoinedSnapshot.data != null) {
                    groupJoined = groupJoinedSnapshot.data.documents.length;
                  }
                  return Scaffold(
                    backgroundColor: Theme.of(context).backgroundColor,
                    floatingActionButton: Tooltip(
                      message: "Create group",
                      child: FloatingActionButton(
                        onPressed: () {
                          Get.toNamed(CreateGroup.route_name).then(
                            (value) {
                              if (value != null) {
                                setState(() {});
                              }
                            },
                          );
                        },
                        child: Icon(
                          Icons.create,
                        ),
                      ),
                    ),
                    body: SingleChildScrollView(
                      child: SafeArea(
                        top: true,
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 100,
                                width: 100,
                                padding: const EdgeInsets.all(
                                  15.0,
                                ),
                                child: ClipOval(
                                  child: FadeInImage(
                                    image: NetworkImage(
                                      userData.get(
                                          FirestoreConstants.USER_PROFILE_PIC),
                                    ),
                                    placeholder: AssetImage(
                                      "assets/default_profile.png",
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                userData.get(FirestoreConstants.USER_NAME),
                                style: GoogleFonts.asap(
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              ProfileGroupDetails(groupOwner, groupJoined,
                                  FirebaseAuth.instance.currentUser.uid),
                              Divider(),
                              GroupOptions(
                                  FirebaseAuth.instance.currentUser.uid),
                              Divider(),
                              // SettingOptions(),
                              if (Platform.isAndroid) OtherOptions(userData),
                              Divider(),
                              ListTile(
                                onTap: () {
                                  Get.defaultDialog(
                                    title: "Logout",
                                    content: Text(
                                      "Sure you want to log out?",
                                      style: GoogleFonts.asap(),
                                    ),
                                    textConfirm: "Yes",
                                    confirmTextColor: Colors.white,
                                    onConfirm: () {
                                      authController.logOut();
                                      Get.back();
                                    },
                                  );
                                },
                                title: Text(
                                  "Log Out",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.asap(
                                    fontSize: 20,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
