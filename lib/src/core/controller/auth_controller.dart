import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:group_chat/src/screens/auth_screen.dart';
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
    _handleSignIn().then((User user) {
      setUserData(user);
    }).catchError((e) {
      print(e.toString());
      Utility.showSnackBar(
        "Not able to sign in with your selected google account. Please try again.",
        Colors.red,
      );
      updateLoading();
    });
  }

  Future<User> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;
    return user;
  }

  void setUserData(User user) {
    FirebaseFirestore.instance
        .collection(FirestoreConstants.USER)
        .doc(user.uid)
        .set({
      FirestoreConstants.USER_ID: user.uid,
      FirestoreConstants.USER_NAME: user.displayName,
      FirestoreConstants.USER_PROFILE_PIC: user.photoURL,
      FirestoreConstants.GET_DAILY_NOTIFICATION: true,
    }).then((_) {
      // check if user is already in the group
      FirebaseFirestore.instance
          .collection(FirestoreConstants.USER)
          .doc(user.uid)
          .collection(FirestoreConstants.GROUPS)
          .where(FirestoreConstants.GROUP_NAME,
              isEqualTo: StringConstant.APP_NAME)
          .get()
          .then((value) {
        if (value.docs.length > 0) {
          updateLoading();
          Get.offNamed(HomeScreen.route_name);
        } else {
          // add user to the group
          DocumentReference documentReference = FirebaseFirestore.instance
              .collection(FirestoreConstants.GROUPS)
              .doc(StringConstant.APP_NAME);

          documentReference
              .collection(FirestoreConstants.USER)
              .doc(user.uid)
              .set({
            FirestoreConstants.JOINED_ON: DateTime.now().millisecondsSinceEpoch,
            FirestoreConstants.IS_OWNER: false,
            FirestoreConstants.USER_ID: user.uid,
          }).then((value) {
            // add group to the user
            FirebaseFirestore.instance
                .collection(FirestoreConstants.USER)
                .doc(user.uid)
                .collection(FirestoreConstants.GROUPS)
                .doc(StringConstant.APP_NAME)
                .set({
              FirestoreConstants.IS_OWNER: false,
              FirestoreConstants.GROUP_NAME: StringConstant.APP_NAME,
              FirestoreConstants.GROUP_REFERENCE:
              documentReference
            }).then((value) {
              // add a message for the group
              FirebaseFirestore.instance
                  .collection(FirestoreConstants.GROUPS)
                  .doc(StringConstant.APP_NAME)
                  .collection(FirestoreConstants.MESSAGES)
                  .doc()
                  .set({
                FirestoreConstants.MESSAGE_ON:
                DateTime
                    .now()
                    .millisecondsSinceEpoch,
                FirestoreConstants.IS_JOINED_MESSAGE: true,
                FirestoreConstants.MESSAGE_BY: user.uid,
                FirestoreConstants.MESSAGE: "${user
                    .displayName} joined the group",
                FirestoreConstants.USER_NAME: "${user.displayName}",
                FirestoreConstants.USER_PROFILE_PIC: "${user.photoURL}",
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
      Get.offNamed(AuthScreen.route_name);
    });
  }
}
