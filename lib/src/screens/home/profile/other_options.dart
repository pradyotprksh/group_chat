import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info/package_info.dart';

class OtherOptions extends StatelessWidget {
  final InAppReview inAppReview = InAppReview.instance;

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
                  applicationVersion: packageSnapshot.data.version,
                  applicationLegalese: 'Welcome to our Groupee.',
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
