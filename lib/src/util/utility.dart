import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Utility {
  static showSnackBar(message, backgroundColor) {
    Get.rawSnackbar(
      dismissDirection: SnackDismissDirection.HORIZONTAL,
      backgroundColor: backgroundColor,
      message: message,
      margin: EdgeInsets.all(
        15.0,
      ),
      borderRadius: 15.0,
    );
  }

  static showLoadingDialog(message) {
    Get.defaultDialog(
      content: Column(
        children: [
          LinearProgressIndicator(),
          SizedBox(
            height: 15,
          ),
          Text(
            message,
            style: GoogleFonts.asap(),
          ),
        ],
      ),
    );
  }

  static String getTimeFromTimeStamp(int timeStamp) {
    return DateFormat("dd-MMM-yyyy' at 'HH:mm a").format(
      DateTime.fromMillisecondsSinceEpoch(
        timeStamp,
      ),
    );
  }
}
