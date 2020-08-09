import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';

class OtherOptions extends StatelessWidget {
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
              onTap: () {
                showAboutDialog(
                  context: context,
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
