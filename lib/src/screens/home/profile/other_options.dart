import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat/src/screens/razorpay_screen.dart';
import 'package:group_chat/src/util/string.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info/package_info.dart';

class OtherOptions extends StatelessWidget {
  final InAppReview inAppReview = InAppReview.instance;

  final DocumentSnapshot userDataSnapshot;

  OtherOptions(this.userDataSnapshot);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (_, packageSnapshot) {
        if (packageSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: LinearProgressIndicator(),
          );
        }
        return Column(
          children: [
            ListTile(
              title: Text(
                "Others",
                style: GoogleFonts.asap(
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Get.toNamed(RazorPayScreen.route_name,
                    arguments: userDataSnapshot);
              },
              title: Text(
                'Donate',
                style: GoogleFonts.asap(),
              ),
              subtitle: Text(
                'Contribute a small amount for us to help us grow.',
                style: GoogleFonts.asap(),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
              ),
            ),
            ListTile(
              onTap: () {
                FlutterShare.share(
                  title: StringConstant.APP_NAME,
                  text:
                  "Hey Friend, checkout this group chat application. Simple and easy to use.",
                  linkUrl:
                  "https://play.google.com/store/apps/details?id=com.project.pradyotprakash.group_chat",
                );
              },
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
              onTap: () async {
                if (await inAppReview.isAvailable()) {
                  inAppReview.requestReview();
                }
              },
              title: Text(
                "Review",
                style: GoogleFonts.asap(),
              ),
              subtitle: Text(
                "Review Groupee Application.",
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
                  applicationIcon: Image.asset(
                    "assets/ic_launcher.png",
                    height: 50,
                    width: 50,
                  ),
                  applicationName: StringConstant.APP_NAME,
                  applicationVersion: packageSnapshot.data.version,
                  applicationLegalese:
                  'A place where all the groups will meet together.',
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
          ],
        );
      },
    );
  }
}
