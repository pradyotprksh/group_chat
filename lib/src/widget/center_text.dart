import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CenterText extends StatelessWidget {
  final String stringValue;

  CenterText(this.stringValue);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        stringValue,
        style: GoogleFonts.asap(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    );
  }
}
