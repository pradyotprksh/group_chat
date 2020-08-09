import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:group_chat/src/screens/home/home_screen.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/utility.dart';

class AuthController extends GetxController {
  var isLoading = false;

  updateLoading() {
    isLoading = !isLoading;
    update();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void loginWithGoogle() {
    updateLoading();
    _handleSignIn().then((FirebaseUser user) {
      setUserData(user);
    }).catchError((e) {
      Utility.showSnackBar(
        "Not able to sign in with your selected google account. Please try again.",
        Colors.red,
      );
      updateLoading();
    });
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    return user;
  }

  void setUserData(FirebaseUser user) {
    Firestore.instance
        .collection(FirestoreConstants.USER)
        .document(user.uid)
        .setData({
      FirestoreConstants.USER_ID: user.uid,
      FirestoreConstants.USER_NAME: user.displayName,
      FirestoreConstants.USER_PROFILE_PIC: user.photoUrl,
    }).then((_) {
      if (user.uid != "74NeqBt63fV2PwKO3rPGIGIchAX2") {
        Firestore.instance
            .collection(FirestoreConstants.GROUPS)
            .document("Groupee")
            .collection(FirestoreConstants.USER)
            .document(user.uid)
            .setData({
          FirestoreConstants.JOINED_ON: DateTime.now().millisecondsSinceEpoch,
          FirestoreConstants.IS_OWNER: false,
          FirestoreConstants.USER_ID: user.uid,
        }).then((value) {
          Firestore.instance
              .collection(FirestoreConstants.USER)
              .document(user.uid)
              .collection(FirestoreConstants.GROUPS)
              .document("Groupee")
              .setData({
            FirestoreConstants.GROUP_NAME: "Groupee",
            FirestoreConstants.GROUP_DESCRIPTION:
                "A place where all the groupee will meet together",
            FirestoreConstants.CREATED_BY: "74NeqBt63fV2PwKO3rPGIGIchAX2",
            FirestoreConstants.IS_OWNER: false,
            FirestoreConstants.GROUP_PROFILE_IMAGE:
                "https://image.flaticon.com/icons/png/512/16/16016.png",
            FirestoreConstants.GROUP_BACKGROUND_IMAGE:
                "https://images.unsplash.com/photo-1506869640319-fe1a24fd76dc?ixlib=rb-1.2.1&auto=format&fit=crop&w=2550&q=80",
          }).then((value) {
            updateLoading();
            Get.offNamed(HomeScreen.route_name);
          });
        });
      } else {
        updateLoading();
        Get.offNamed(HomeScreen.route_name);
      }
    }).catchError((_) {
      Utility.showSnackBar(
        "Not able to get your details. Please try again.",
        Colors.red,
      );
      updateLoading();
    });
  }

  Future<void> logOut() async {
    FirebaseAuth.instance.signOut().then((value) {
      Get.offNamed("/");
    });
  }
}
