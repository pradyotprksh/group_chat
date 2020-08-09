import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  static String getTimeFromTimeStamp(int timeStamp) {
    return DateFormat("dd-MMM-yyyy' at 'HH:mm a").format(
      DateTime.fromMillisecondsSinceEpoch(
        timeStamp,
      ),
    );
  }
}
