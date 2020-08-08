import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/util/firestore_constants.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (_, currentUserSnapshot) {
        if (currentUserSnapshot.connectionState == ConnectionState.waiting) {
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
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
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
                return SingleChildScrollView(
                  child: SafeArea(
                    top: true,
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(
                              15.0,
                            ),
                            child: ClipOval(
                              child: FadeInImage(
                                image: NetworkImage(
                                  userData[FirestoreConstants.USER_PROFILE_PIC],
                                ),
                                placeholder: AssetImage(
                                  "assets/default_profile.png",
                                ),
                              ),
                            ),
                          ),
                          Text(
                            userData[FirestoreConstants.USER_NAME],
                            style: GoogleFonts.asap(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
