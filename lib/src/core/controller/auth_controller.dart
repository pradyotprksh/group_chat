import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:group_chat/src/screens/home/home_screen.dart';
import 'package:group_chat/src/util/firestore_constants.dart';
import 'package:group_chat/src/util/string.dart';
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
      // check if user is already in the group
      Firestore.instance
          .collection(FirestoreConstants.USER)
          .document(user.uid)
          .collection(FirestoreConstants.GROUPS)
          .where(FirestoreConstants.GROUP_NAME,
              isEqualTo: StringConstant.APP_NAME)
          .getDocuments()
          .then((value) {
        if (value.documents.length > 0) {
          updateLoading();
          Get.offNamed(HomeScreen.route_name);
        } else {
          // add user to the group
          DocumentReference documentReference = Firestore.instance
              .collection(FirestoreConstants.GROUPS)
              .document(StringConstant.APP_NAME);

          documentReference
              .collection(FirestoreConstants.USER)
              .document(user.uid)
              .setData({
            FirestoreConstants.JOINED_ON: DateTime.now().millisecondsSinceEpoch,
            FirestoreConstants.IS_OWNER: false,
            FirestoreConstants.USER_ID: user.uid,
          }).then((value) {
            // add group to the user
            Firestore.instance
                .collection(FirestoreConstants.USER)
                .document(user.uid)
                .collection(FirestoreConstants.GROUPS)
                .document(StringConstant.APP_NAME)
                .setData({
              FirestoreConstants.IS_OWNER: false,
              FirestoreConstants.GROUP_NAME: StringConstant.APP_NAME,
              FirestoreConstants.GROUP_REFERENCE:
              documentReference
            }).then((value) {
              // add a message for the group
              Firestore.instance
                  .collection(FirestoreConstants.GROUPS)
                  .document(StringConstant.APP_NAME)
                  .collection(FirestoreConstants.MESSAGES)
                  .document()
                  .setData({
                FirestoreConstants.MESSAGE_ON:
                DateTime
                    .now()
                    .millisecondsSinceEpoch,
                FirestoreConstants.IS_JOINED_MESSAGE: true,
                FirestoreConstants.MESSAGE_BY: user.uid,
                FirestoreConstants.MESSAGE: "${user
                    .displayName} joined the group",
                FirestoreConstants.USER_NAME: "${user.displayName}",
                FirestoreConstants.USER_PROFILE_PIC: "${user.photoUrl}",
              }).then((value) {
                updateLoading();
                Get.offNamed(HomeScreen.route_name);
              });
            });
          });
        }
      });
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
