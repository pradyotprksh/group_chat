import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
      ],
    );
  }
}
