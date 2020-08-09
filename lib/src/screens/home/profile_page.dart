import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/create_group.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:package_info/package_info.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (_, packageSnapshot) {
        if (packageSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder: (_, currentUserSnapshot) {
            if (currentUserSnapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (currentUserSnapshot.data == null) {
              return Center(
                child: Text(
                  "Something Went Wrong while getting user data.",
                  style: GoogleFonts.asap(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              );
            } else {
              return FutureBuilder(
                future: Firestore.instance
                    .collection(FirestoreConstants.USER)
                    .document(currentUserSnapshot.data.uid)
                    .get(),
                builder: (_, userDataSnapshot) {
                  if (userDataSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (userDataSnapshot.data == null) {
                    return Center(
                      child: Text(
                        "Something Went Wrong while getting user data.",
                        style: GoogleFonts.asap(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    );
                  } else {
                    var userData = userDataSnapshot.data;
                    return FutureBuilder(
                      future: Firestore.instance
                          .collection(FirestoreConstants.USER)
                          .document(currentUserSnapshot.data.uid)
                          .collection(FirestoreConstants.GROUPS)
                          .where(FirestoreConstants.IS_OWNER, isEqualTo: true)
                          .getDocuments(),
                      builder: (_, groupOwnerSnapshot) {
                        if (groupOwnerSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        var groupOwner = 0;
                        if (groupOwnerSnapshot.data != null) {
                          groupOwner = groupOwnerSnapshot.data.documents.length;
                        }
                        return FutureBuilder(
                          future: Firestore.instance
                              .collection(FirestoreConstants.USER)
                              .document(currentUserSnapshot.data.uid)
                              .collection(FirestoreConstants.GROUPS)
                              .getDocuments(),
                          builder: (_, groupJoinedSnapshot) {
                            if (groupJoinedSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            var groupJoined = 0;
                            if (groupJoinedSnapshot.data != null) {
                              groupJoined =
                                  groupJoinedSnapshot.data.documents.length;
                            }
                            return Scaffold(
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              floatingActionButton: (userData[
                                              FirestoreConstants.GROUP_OWNER] ==
                                          null ||
                                      userData[FirestoreConstants.GROUP_OWNER] >
                                          0)
                                  ? Tooltip(
                                      message: "Create group",
                                      child: FloatingActionButton(
                                        onPressed: () {
                                          Get.toNamed(CreateGroup.route_name)
                                              .then((value) {
                                            if (value != null) {
                                              print(value);
                                            }
                                          });
                                        },
                                        child: Icon(
                                          Icons.create,
                                        ),
                                      ),
                                    )
                                  : Container(),
                              body: SingleChildScrollView(
                                child: SafeArea(
                                  top: true,
                                  child: Container(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                                userData[FirestoreConstants
                                                    .USER_PROFILE_PIC],
                                              ),
                                              placeholder: AssetImage(
                                                "assets/default_profile.png",
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          userData[
                                              FirestoreConstants.USER_NAME],
                                          style: GoogleFonts.asap(
                                            fontSize: 20,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30.0,
                                        ),
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () {},
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
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
                                                      textAlign:
                                                          TextAlign.center,
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
                                              onTap: () {},
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
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
                                                      textAlign:
                                                          TextAlign.center,
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
                                        ),
                                        Divider(),
                                        ListTile(
                                          title: Text(
                                            "Profile",
                                            style: GoogleFonts.asap(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          onTap: () {},
                                          title: Text(
                                            "Edit Profile",
                                            style: GoogleFonts.asap(),
                                          ),
                                          subtitle: Text(
                                            "Edit your profile details.",
                                            style: GoogleFonts.asap(),
                                          ),
                                          trailing: Icon(
                                            Icons.keyboard_arrow_right,
                                          ),
                                        ),
                                        Divider(),
                                        ListTile(
                                          title: Text(
                                            "Groups",
                                            style: GoogleFonts.asap(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          onTap: () {},
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
                                          onTap: () {},
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
                                          onTap: () {},
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
                                        ListTile(
                                          onTap: () {},
                                          title: Text(
                                            "Configure Groups",
                                            style: GoogleFonts.asap(),
                                          ),
                                          subtitle: Text(
                                            "Configure basic group settings.",
                                            style: GoogleFonts.asap(),
                                          ),
                                          trailing: Icon(
                                            Icons.keyboard_arrow_right,
                                          ),
                                        ),
                                        Divider(),
                                        ListTile(
                                          title: Text(
                                            "Others",
                                            style: GoogleFonts.asap(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          onTap: () {},
                                          title: Text(
                                            "Share",
                                            style: GoogleFonts.asap(),
                                          ),
                                          subtitle: Text(
                                            "Share Groupee with your friends.",
                                            style: GoogleFonts.asap(),
                                          ),
                                          trailing: Icon(
                                            Icons.keyboard_arrow_right,
                                          ),
                                        ),
                                        ListTile(
                                          onTap: () {
                                            showAboutDialog(
                                              context: context,
                                              applicationVersion:
                                                  packageSnapshot.data.version,
                                              applicationLegalese:
                                                  'Welcome to our Groupee.',
                                            );
                                          },
                                          title: Text(
                                            "About",
                                            style: GoogleFonts.asap(),
                                          ),
                                          subtitle: Text(
                                            "About Groupee.",
                                            style: GoogleFonts.asap(),
                                          ),
                                          trailing: Icon(
                                            Icons.keyboard_arrow_right,
                                          ),
                                        ),
                                        Divider(),
                                        ListTile(
                                          onTap: () {},
                                          title: Text(
                                            "Log Out",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.asap(
                                              fontSize: 20,
                                              color:
                                                  Theme.of(context).accentColor,
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
          },
        );
      },
    );
  }
}
